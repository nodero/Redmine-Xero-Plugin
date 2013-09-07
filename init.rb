require 'rubygems'
require 'xeroizer'

Redmine::Plugin.register :xero do
  name 'Xero plugin'
  author 'Nodero Ltd'
  description 'Xero plugin for Redmine'
  version '0.0.1'
  url 'http://nodero.com/path/to/plugin'
  author_url 'http://nodero.com'
  permission :xero, { :xero => [:index, :settings, :project, :generate_invoice] }, :public => true
  menu :project_menu, :xero, { :controller => 'xero', :action => 'index' }, :caption => 'Xero', :after => :settings, :param => :project
  menu :admin_menu, :xero, { :controller => 'xero', :action => 'settings'}, :caption => 'Xero settings'
end
