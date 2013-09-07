class XeroController < ApplicationController
  
  @@xero = Xeroizer::PrivateApplication.new('YPXQHAJ0WAPVKQXK4EOA9OEIOQDSWP', 'ZQLFONS2RIINL46NGLGEY1MVOWAAP9', "/home/redmine/redmine/plugins/xero/privatekey.pem")
  def xero
    @@xero
  end
  
  def consumer_key
	'YPXQHAJ0WAPVKQXK4EOA9OEIOQDSWP'
  end
  
  def consumer_secret
	'ZQLFONS2RIINL46NGLGEY1MVOWAAP9'
  end


  def index
	
	@contacts = self.xero.Contact.all(:order => 'Name')
	#@invoices = XeroController.xero.Invoice.all(:where => {:type => 'ACCREC', :amount_due_is_not => 0})
	
	@project = Project.find(params[:project])
	
	#flash[:notice] = "Hello."
	
	features = @project.issues.find(:all, :conditions => 'tracker_id = 2', :order => "created_on ASC")
	
	@rows = []
	
	features.each do |feature|
		if feature.total_spent_hours > 0
			@rows.push({
				:id => feature.id, 
				:subject => feature.subject, 
				:description => feature.description, 
				:total_spent_hours => feature.total_spent_hours,
				:hours => TimeEntry.sum(:hours, :conditions => [ "issue_id = ?", feature.id ] ).to_f 
			})
		end
		#hours = TimeEntry.sum(:hours, :conditions => [ "issue_id = ?", feature.id ] ).to_f
	end
	
	@issues = @project.issues.find(:all)
	#@hours = TimeEntry.sum(:hours, :conditions => ['issue_id IN (?)', @issues]).to_f
  end

  def settings
	@consumer_key = self.consumer_key
	@consumer_secret = self.consumer_secret
  end

  def project
  end
  
  def generate_invoice
	#@project = Project.find(params[:projectid])

	#@features = @project.issues.find(:all, :conditions => 'tracker_id = 2', :order => "created_on ASC")
	
#	@issues = @project.issues.find(:all)
#	@hours = TimeEntry.sum(:hours, :conditions => ['issue_id IN (?)', @issues]).to_f

	project = Project.find(params[:project_id])
	
	@query = TimeEntryQuery.build_from_params(params, :project => project, :name => '_')
	
	Rails.logger.info "Query: " << @query
	
	features = project.issues.find(:all, :conditions => 'tracker_id = 2', :order => "created_on ASC")
		
	contact = self.xero.Contact.find(params[:contact_id])

	invoice = self.xero.Invoice.build(:type => 'ACCREC', 
								 :status => 'DRAFT', 
								 :line_amount_types =>'Exclusive', 
								 :contact => contact )

	features.each do |feature|
		
		@hours = feature.total_spent_hours.to_f

		Rails.logger.info "Time entry hours: " << @hours.to_s

		invoice.add_line_item(:description => feature.subject,
							  :quantity => @hours,
							  :unit_amount => "200.00"
							 )
	end		

	invoice.save

    #flash[:notice] = "Invoice created."
	
	redirect_to :action => 'index', :project => project.identifier
  end
end