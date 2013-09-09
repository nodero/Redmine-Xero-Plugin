class XeroController < ApplicationController
  unloadable

  before_filter :authorize, :only => :index 
  before_filter :authorize, :only => :generate_invoice

  def xero
	@@xero ||= Xeroizer::PrivateApplication.new(self.consumer_key, self.consumer_secret, "/home/redmine/redmine/plugins/xero/privatekey.pem")
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
	Rails.logger.info "Key: " << self.consumer_key
	Rails.logger.info "Secret: " << self.consumer_secret
  
	
	@contacts = self.xero.Contact.all(:order => 'Name')
		
	@project = Project.find(params[:project])
			
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
	#@consumer_key = self.consumer_key
	#@consumer_secret = self.consumer_secret
	#@settings = Setting.plugin_xero
  end

  def project
  end
  
  def generate_invoice
	project = Project.find(params[:project_id])
	
	features = project.issues.find(:all, :conditions => 'tracker_id = 2 AND parent_id IS NULL', :order => "created_on ASC")
		
	contact = self.xero.Contact.find(params[:contact_id])

	invoice = self.xero.Invoice.build(:type => 'ACCREC', 
								 :status => 'DRAFT', 
								 :line_amount_types =>'Exclusive', 
								 :contact => contact )

	features.each do |feature|
		
		#@hours = feature.total_spent_hours.to_f
		from = Date.parse(params[:date_from])
		to = Date.parse(params[:date_to])


		Rails.logger.info "from: " << from.to_s
		Rails.logger.info "to: " << to.to_s

		@hours = 0 

		scope = TimeEntry.visible.spent_between(from, to).on_issue(feature)

		#scope.sum(:hours, :include => :issue, :group => @criteria.collect{|criteria| @available_criteria[criteria][:sql]} + time_columns).each do |hash, hours|
		@hours = scope.sum(:hours, :include => :issue)

		Rails.logger.info "feature: " << feature.subject
		Rails.logger.info "Time entry hours: " << @hours.to_s
		
		#Only add a line to an invoice if time has been logged for the feature(or any of its sub-features)
		if @hours > 0
			invoice.add_line_item(:description => feature.subject,
							  :quantity => @hours,
							  :unit_amount => "200.00"
							 )
		end
	end		

	Rails.logger.info "Invoice line items: " + invoice.line_items.size.to_s

	#Only save if the invoice has line_items.
	if invoice.line_items.size > 0
		invoice.save
		flash[:notice] = "Invoice created."
	else
		flash[:error] = "Invoice not created. There were no line items."
	end
	
	redirect_to :action => 'index', :project => project.identifier
	
  end
end