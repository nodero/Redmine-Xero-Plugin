Redmine-Xero-Plugin
===================

Minimise your invoicing drag-factor with our Xero plugin for Redmine.

Introduction
-------------------
This plugin has been created to meet the needs of our own business, that is to integrate our time keeping in Redmine with the Xero accounting software.
You are welcome to use/modify this plugin.

Installation
-------------------

1. Install plugin at

        Redmine_root\plugins
2. Make sure you have the required Ruby Gems installed. Inside the `Redmine_root\plugins\xero` folder run `gem install`

3. Run the rake command

        rake redmine:plugins:migrate RAILS_ENV=production
        
4. Place your `privatekey.pem` file in the root of the plugin folder

5. Restart your Redmine web server.

6. Login to Redmine and configure the plugin 

                                                       

        
 







