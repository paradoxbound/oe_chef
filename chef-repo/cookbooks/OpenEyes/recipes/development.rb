#
# Cookbook Name:: OpenEyes
# Recipe:: jenkins
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"

package "ruby"
package "ruby-dev"

gem_package "compass" do
  action :install
end

execute "install composer" do
  command "curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer"
end

execute "add node ppa" do
  command "curl -sL https://deb.nodesource.com/setup | sudo bash -"
end

package "nodejs"

execute "install bower" do
  command "npm install -g bower"
end

execute "install grunt" do
  command "npm install -g grunt-cli"
end
