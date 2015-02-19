#
# Cookbook Name:: OpenEyes
# Recipe:: jenkins
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"

package "git"
package "openjdk-7-jre"
package "openjdk-7-jdk"


execute "jenkins get key" do
  command "wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -"
end

execute "jenkins add repo" do
  command "sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list' && apt-get update"
end

package "jenkins"

execute "install plugins" do
  command "wget http://localhost:8080/jnlpJars/jenkins-cli.jar && java -jar jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin PHP Git github-api GitHub Ant"
end


service "jenkins" do
  supports [:stop, :start, :restart]
  action [:start, :enable]
end
