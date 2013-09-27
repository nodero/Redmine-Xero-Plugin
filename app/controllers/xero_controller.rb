class XeroController < ApplicationController
  unloadable

  #before_filter :authorize, :only => :index 
  #before_filter :authorize, :only => :generate_invoice
  
  def xero
	key_location = File.expand_path("../../../privatekey.pem", __FILE__)
	@@xero ||= Xeroizer::PrivateApplication.new(self.consumer_key, self.consumer_secret, key_location)
  end

  def project

  end
  
  def consumer_key
	#YPXQHAJ0WAPVKQXK4EOA9OEIOQDSWP
	Setting.plugin_xero['consumer_key']
  end
  
  def consumer_secret
	#'ZQLFONS2RIINL46NGLGEY1MVOWAAP9'
	Setting.plugin_xero['consumer_secret']
  end
  
  def index

  	#If both start and end date parameters provided then set them up
  	if params[:start] and params[:end]
  	  begin
	  	@start_date = Date.strptime(params[:start][:date],"%Y-%m-%d")
	  	@end_date = Date.strptime(params[:end][:date],"%Y-%m-%d").end_of_day
	  rescue
	  	Rails.logger.info "Start Date and/or End Date not valid"
	  end
	end
	
	#set start and end date to start/end of current month if they have no values
	@start_date ||= Date.today.beginning_of_month
    @end_date ||= Date.today.end_of_month.end_of_day

    Rails.logger.info "Start Date: " << @start_date.to_s
    Rails.logger.info "End Date: " << @end_date.to_s	
	
	if(self.consumer_key.nil? || self.consumer_secret.nil?)
		redirect_to :action => 'index'
	end
	
	#get list of all contacts from Xero	
	@contacts = self.xero.Contact.all(:order => 'Name')
		
	@project = Project.find(params[:project])
	Rails.logger.info "Project: " << self.consumer_secret	

	#find xero details for project if they exist, if they do not then set one up - but not saved yet
	@xero_details = ProjectXeroDetails.where(:project_id => @project.id).first_or_initialize

	if(@xero_details.new_record?) 
		flash[:error] = "You must set Xero Details for the project before you can generate an invoice"
	end
	
	#Select all time logged for project for given time period where time is not set as 'Non-billable' and hasn't already been invoiced
	@billable_issues = Issue.find_by_sql(
			"select ri.root_id as id,
       		ri.subject,
       		ri.description,
	        ri.project_id,
	        sum(te.hours) as total_spent_hours
	        from time_entries te join issues i on te.issue_id = i.id
	        join issues ri on i.root_id = ri.id
	        left join custom_values cv on i.id = cv.customized_id and cv.customized_type = 'Issue'
	        left join custom_fields cf on cv.custom_field_id = cf.id and cf.name = 'Billable'
	        where te.project_id = " + @project.id.to_s + "
		    and te.invoiced = 0
		    and te.created_on between '" + @start_date.to_s + "' and '" + @end_date.to_s + "'
	        and (cv.value != 'Non-billable' AND cv.value IS NOT NULL)
	        group by i.root_id;"
		)

  end
  
  def generate_invoice
	project = Project.find(params[:project])

	xero_details = ProjectXeroDetails.where(:project_id => project.id).first
	
	contact = self.xero.Contact.find(xero_details.xero_contact_id)

	invoice = self.xero.Invoice.build(:type => 'ACCREC', 
								 :status => 'DRAFT', 
								 :line_amount_types =>'Exclusive', 
								 :contact => contact )

	params[:features].each do |feature|
		#If the billable key is in the hash array then the checkbox has been selected
		if feature.has_key?("billable")	

			Rails.logger.info "feature: " << feature["subject"]
			Rails.logger.info "Time entry hours: " << feature["total_spent_hours"]
			
			#Only add a line to an invoice if time has been logged for the feature(or any of its sub-features)
			if feature["total_spent_hours"].to_f > 0
				invoice.add_line_item(:description => feature["subject"],
								  :quantity => feature["total_spent_hours"],
								  :unit_amount => feature["rate"]
								 )
			end
		end
	end		

	Rails.logger.info "Invoice line items: " + invoice.line_items.size.to_s

	#Only save if the invoice has line_items.
	if invoice.line_items.size > 0
		#line below commented out for testing purposes, if you want it to really create the invoice in Xero, remove comment
		#invoice.save
		flash[:notice] = "Invoice created."
	else
		flash[:error] = "Invoice not created. There were no line items."
	end
	
	# TO DO --update time spent that has been invoiced so that it will not be included in future invoicing.

	redirect_to :action => 'index', :project => project.identifier
	
  end

  def save_billing_details

  	@xero_details = ProjectXeroDetails.where(:project_id => params[:project_xero_details][:project_id]).first_or_initialize

  	@xero_details.attributes = params[:project_xero_details]

  	Rails.logger.info "xero_contact_id: " << @xero_details.xero_contact_id
    Rails.logger.info "project_id: " << @xero_details.project_id.to_s
    Rails.logger.info "rate: " << @xero_details.rate.to_s

	@xero_details.save
  	
  	flash[:notice] = "Details saved."
    redirect_to :action => 'index', :project => @xero_details.project_id
  end

end