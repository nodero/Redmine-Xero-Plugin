# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'xero', :to => 'xero#index'
get 'settings/plugin/xero', :to => 'xero#settings'
post 'xero/generate_invoice', :to => 'xero#generate_invoice'
post 'xero/save_billing_details', :to => 'xero#save_billing_details'