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

mysql_config 'openeyes' do
  source 'oe_extra_settings.erb'
  notifies :restart, 'mysql_service[openeyes]'
  action :create
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

package 'php5-xsl' do
  action :install
end

package 'php5-curl' do
  action :install
end

package 'libjpeg62' do
  action :install
end

package 'wkhtmltopdf' do
  action :install
end

##

## Create the db then populate it
execute "create OpenEyes Database" do
  command "mysqladmin -uroot -popeneyes -h 127.0.0.1 create openeyes"
end

# populate the db with sample data
execute " import sample data" do
  command "cd /tmp && git clone https://github.com/openeyes/Sample.git sample"
end

execute "populate db" do
  command "mysql -uroot -popeneyes -h 127.0.0.1 -D openeyes < /tmp/sample/sql/openeyes.sql"
end

# Install OpenEyes

execute "git clone oe" do
  command "cd /var/www && git clone -b develop https://github.com/openeyes/OpenEyes.git openeyes"
end

## Install modules

execute "git clone OphCoCorrespondence" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphCoCorrespondence.git OphCoCorrespondence"
end

execute "git clone OphDrPrescription" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphDrPrescription.git OphDrPrescription"
end

execute "git clone OphTrOperationnote" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphTrOperationnote.git OphTrOperationnote"
end

execute "git clone OphCiExamination" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphCiExamination.git OphCiExamination"
end

execute "git clone OphOuAnaestheticsatisfactionaudit" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphOuAnaestheticsatisfactionaudit.git OphOuAnaestheticsatisfactionaudit"
end

execute "git clone OphLeEpatientletter" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphLeEpatientletter.git OphLeEpatientletter"
end

execute "git clone OphTrOperationbooking" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphTrOperationbooking.git OphTrOperationbooking"
end

execute "git clone OphCiPhasing" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphCiPhasing.git OphCiPhasing"
end

execute "git clone OphTrConsent" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphTrConsent.git OphTrConsent"
end

execute "git clone eyedraw" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/eyedraw.git eyedraw"
end


execute "git clone mehpas" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/mehpas.git mehpas"
end


execute "git clone OphTrIntravitrealinjection" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphTrIntravitrealinjection.git OphTrIntravitrealinjection"
end

execute "git clone OphLeIntravitrealinjection" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphLeIntravitrealinjection.git OphLeIntravitrealinjection"
end

execute "git clone OphCoTherapyapplication" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphCoTherapyapplication.git OphCoTherapyapplication"
end

execute "git clone OphTrLaser" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphTrLaser.git OphTrLaser"
end

execute "git clone MEHBookingLogger" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/MEHBookingLogger.git MEHBookingLogger"
end

execute "git clone OphInVisualfields" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/OphInVisualfields.git OphInVisualfields"
end

execute "git clone PatientTicketing" do
command "cd /var/www/openeyes/protected/modules && git clone  https://github.com/openeyes/PatientTicketing.git PatientTicketing"
end



## index and .htaccess
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
# Yii and modules

execute "initialize Yii" do
  command " cd /var/www/openeyes;  git submodule init; git submodule update"
end

execute "migrate Yii" do
  command "cd /var/www/openeyes/protected; ./yiic migrate --interactive=0"
end

execute "import modules" do
  command "cd /var/www/openeyes/protected && ./yiic migratemodules --interactive=0"
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
execute "OpenEyes permission" do
  command "chown -R www-data:www-data /var/www/openeyes"
end

service 'apache2' do
  action [ :restart ]
end


