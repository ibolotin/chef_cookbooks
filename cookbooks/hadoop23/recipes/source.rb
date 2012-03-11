#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright 2011, Robin Wenglewski
#
# All rights reserved - Do Not Redistribute
#
hadoop_user = node[:hadoop][:username]
hadoop_path = node[:hadoop][:path]
hadoop_conf_path = File.join(hadoop_path, "conf")

include_recipe "java"

package "libshadow-ruby1.8"

# ln -s /usr/bin/java /bin/java
link "/bin/java" do
  to "/usr/bin/java"
end

#creating the hadoop username
user "#{hadoop_user}" do
  comment "Hadoop User"
  home "/home/#{hadoop_user}"
  shell "/bin/bash"
  password "#{node[:hadoop][:password]}"
  action :create 
end

#creating the hadoop home directory
directory "/home/#{hadoop_user}" do
  owner hadoop_user
  group hadoop_user
  mode "0755"
  action :create
end



#creating the hadoop keys directory
directory "/home/#{hadoop_user}/keys" do
  owner hadoop_user
  group hadoop_user
  mode "0755"
  action :create
end

#creating the hadoop .ssh directory
directory "/home/#{hadoop_user}/.ssh" do
  owner hadoop_user
  group hadoop_user
  mode "0755"
  action :create
end

#creating authorized_keys file
file "/home/#{hadoop_user}/.ssh/authorized_keys" do
  owner hadoop_user
  group hadoop_user
  mode "0755"
  action :create
end

#downloading HADOOP archive to ~ and extracting it
remote_file "/home/#{hadoop_user}/#{node[:hadoop][:archive_name]}" do
  source "#{node[:hadoop][:download_url]}"
  owner hadoop_user
  group hadoop_user
  mode "0644"
end



script "extract_hadoop" do
  interpreter "bash"
  #user hadoop_user
  cwd "/home/#{hadoop_user}"
  code <<-EOH
  cd /opt
  tar -zxf /home/#{hadoop_user}/#{node[:hadoop][:archive_name]}
  chown -R #{hadoop_user}:#{hadoop_user} #{hadoop_path}
  EOH
  not_if do
    ::File.exists?(File.join(hadoop_path, "bin", "hadoop"))
  end
end

#updating environment vars
script "update_env_vars" do
  interpreter "bash"
  user "root"
  code <<-EOH
  echo HADOOP_HOME="/opt/#{node[:hadoop][:folder_name]}" >> /etc/environment
  echo HADOOP_INSTALL="/opt/#{node[:hadoop][:folder_name]}" >> /etc/environment
  EOH
end

#creating the hadoop hdfs data directory
[ File.join(node[:hadoop][:path], "hdfs", "datanode"),
  File.join(node[:hadoop][:path], "hdfs", "namenode")].each do |dir|
  directory dir do
    owner hadoop_user
    group hadoop_user
    mode "0755"
    recursive true
    action :create
  end
end

[ "core-site.xml", "hdfs-site.xml", "yarn-site.xml", "mapred-site.xml",
  "hadoop-env.sh", "yarn-env.sh" ].each do |config|
  template config do
    path File.join(hadoop_conf_path, config)
    source "#{config}.erb"
    owner hadoop_user
    group hadoop_user
    mode 0644
  end
end