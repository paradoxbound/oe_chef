#
# Cookbook Name:: OpenEyes
# Recipe:: default
#
# Copyright 2015, OpenEyes Programme
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"

mysql_service 'openeyes' do
  version '5.5'
  bind_address '0.0.0.0'
  port '3306'  
  initial_root_password 'openeyes'
  action [:create, :start]
end



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

## Cp sample data

execute "sample data" do
  command "cd /var/www/openeyes && mkdir protected/config/local"
end

### modules here
cookbook_file "common.php" do
  path "/var/www/openeyes/protected/config/local/common.php"
  action :create_if_missing
end

execute "import modules" do
  command "cd /var/www/openeyes/protected && ./yiic migratemodules"
end

# populate the db with sample data
execute " import sample data" do
  command "cd /tmp && git clone https://github.com/openeyes/Sample.git sample"
end

## Create the db then populate it
execute "create OpenEyes Database" do
  command "mysqladmin -uroot -popeneyes -h 127.0.0.1 create openeyes"
end

execute "populate db" do
  command "mysql -uroot -popeneys -h 127.0.0.1 -D openeyes < /tmp/sample/sql/openeyes.sql"
end

## Create the vhost
cookbook_file "apache.conf" do
  path "/etc/apache2/sites-available/000-default.conf"
  action :create
end

## Enable mod_rew
execute "mode rewrite" do
  command "a2enmod rewrite" 
end

service 'apache2' do
  action [ :restart ]
end


