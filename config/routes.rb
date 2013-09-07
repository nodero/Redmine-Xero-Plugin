# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'xero', :to => 'xero#index'
get 'xero/settings', :to => 'xero#settings'
post 'xero/generate_invoice', :to => 'xero#generate_invoice'