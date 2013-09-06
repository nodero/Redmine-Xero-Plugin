# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'xero', :to => 'xero#index'
post 'xero/generate_invoice', :to => 'xero#generate_invoice'