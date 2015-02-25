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

package 'php5-curl' do
  action :install
end

package 'php5-xsl' do
  action :install
end

package 'git' do
  action :install
end

execute "maria repo" do
  command "sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && sudo add-apt-repository 'deb http://mirror.stshosting.co.uk/mariadb/repo/5.5/ubuntu trusty main' && apt-get update"
end

package "mariadb-server" do
  action :install
end
##

execute "git clone oe" do
  command "cd /var/www && git clone https://github.com/openeyes/OpenEyes.git openeyes"
  not_if do ::File.directory?('/var/www/openeyes') end
end

## Initialise the yii framework:

execute "yii framework" do
  command "cd /var/www/openeyes && git submodule init && git submodule update"
end

## index nad .htaccess
execute "index and htaccess" do
  command "cd /var/www/openeyes && cp index.example.php index.php; cp .htaccess.sample .htaccess"
  not_if do ::File.exists?('/var/www/openeyes/index.php') || ::File.exists?('/var/www/openeyes/.htaccess') end
end

## permissions for the assets, cache and runtime directories
execute "permission" do
  command "mkdir /var/www/openeyes/protected/runtime /var/www/openeyes/cache /var/www/openeyes/protected/cache && chmod 777 /var/www/openeyes/assets /var/www/openeyes/cache /var/www/openeyes/protected/cache /var/www/openeyes/protected/runtime"
  not_if do ::File.directory?('/var/www/openeyes/protected/runtime') end
end

## Cp sampl;e data

execute "sample data" do
  command "cd /var/www/openeyes && mkdir protected/config/local/ && cp protected/config/local.sample/common.sample.php protected/config/local/common.php"
  not_if do ::File.exists?('/var/www/openeyes/protected/config/local/common.php') end
end

### modules here

template "/var/www/openeyes/protected/config/local/common.php" do
  source "common.php.erb"
  variables(
    :oe_modules => "'OphCiExamination', 'OphTrOperationnote', 'Biometry'"
  )
end

execute "setup database" do
  exists = <<-EOH
  mysql -u root -e 'show databases;' | grep #{node[:maria][:oe_db_base]}
  EOH
  command "mysql -u root -e 'CREATE DATABASE #{node[:maria][:oe_db_base]}; create user #{node[:maria][:oe_db_user]}; grant all on #{node[:maria][:oe_db_base]}.* to \"#{node[:maria][:oe_db_user]}\"@\"%\" identified by \"#{node[:maria][:oe_db_pass]}\";'"
  not_if exists
end


## Enable mod_rew
execute "mode rewrite" do
  command "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/"
  not_if do ::File.exists?('/etc/apache2/mods-enabled/rewrite.load') end
end

service 'apache2' do
  action [ :restart ]
end
