#
# Cookbook Name:: OpenEyes
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"

package 'apache2' do
  action :install
end

service 'apache2' do
  action [ :enable, :start ]
end



package 'libapache2-mod-php5' do
  action :install
end

package 'php5-cli' do
  action :install
end

package 'php5-mysql' do
  action :install
end

package 'php5-ldap' do
  action :install
end

##

execute "git clone oe" do
  command "cd /var/www && git clone https://github.com/openeyes/OpenEyes.git openeyes"
end

## Initialise the yii framework:

execute "yii framework" do
  command "cd /var/www/openeyes && git submodule init && git submodule update"
end

## index nad .htaccess
execute "index and htaccess" do
  command "cd /var/www/openeyes && mv index.example.php index.php; mv .htaccess.sample .htaccess"
end

## permissions for the assets, cache and runtime directories
execute "permission" do
  command "mkdir /var/www/openeyes/protected/runtime /var/www/openeyes/cache /var/www/openeyes/protected/cache && chmod 777 /var/www/openeyes/assets /var/www/openeyes/cache /var/www/openeyes/protected/cache /var/www/openeyes/protected/runtime"
end

## Cp sampl;e data

execute "sample data" do
  command "cd /var/www/openeyes && mkdir protected/config/local/ && cp protected/config/local.sample/common.sample.php protected/config/local/common.php"
end

### modules here

template "/var/www/openeyes/protected/config/local/common.php" do
  source "common.php.erb"
  variables( :oe_modules => "OphCiExamination, OphTrOperationnote, Biometry" )
end

## Enable mod_rew
execute "mode rewrite" do
  command "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/" 
end

service 'apache2' do
  action [ :restart ]
end
