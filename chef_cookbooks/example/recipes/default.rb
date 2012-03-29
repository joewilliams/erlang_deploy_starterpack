## Copyright 2012, Joe Williams <joe@joetify.com>
##
## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use,
## copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following
## conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
## HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
## WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## OTHER DEALINGS IN THE SOFTWARE.

# install runit

include_recipe "runit"

# setup the user and group for your erlang release to run as

group node[:example][:group] do
  gid node[:example][:gid]
end

user node[:example][:user] do
  uid node[:example][:uid]
  gid node[:example][:gid]
  home node[:example][:path]
  shell "/bin/bash"
  system true
end

# download the release

remote_file "/tmp/example.tar.gz" do
  source "#{node[:example][:repo_url]}/example_#{node[:example][:version]}.tar.gz"
  not_if "/usr/bin/test -d #{node[:example][:path]}"
end

#install the release

bash "install example" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  (tar zxf /tmp/example.tar.gz -C #{node[:example][:install_dir]})
  (chown -R #{node[:example][:user]}:#{node[:example][:user]} #{node[:example][:path]})
  (rm -f /tmp/example.tar.gz)
  EOH
  not_if "/usr/bin/test -d #{node[:example][:path]}"
end

# use a specific run script to start the release

template "#{node[:example][:path]}/bin/example_run" do
  source "example_run.erb"
  mode 0755
  owner node[:example][:user]
  group node[:example][:group]
end

# create a log dir your release can write to

directory node[:example][:log_dir] do
  owner node[:example][:user]
  group node[:example][:group]
end

# create a data dir your release can write to (not always needed)

directory node[:example][:data_dir] do
  owner node[:example][:user]
  group node[:example][:group]
end

# setup the runit service to manage your release

runit_service "example"

service "example" do
  supports :status => true, :restart => true
  action [ :start ]
end

# apply a custom sys.config template

template "#{node[:example][:path]}/releases/#{node[:example][:version]}/sys.config" do
  source "sys.config.erb"
  mode 655
  owner node[:example][:user]
  group node[:example][:group]
  notifies(:restart, resources(:service => "example"))
end

# apply a custom vm.args template

template "#{node[:example][:path]}/releases/#{node[:example][:version]}/vm.args" do
  source "vm.args.erb"
  mode 0644
  owner node[:example][:user]
  group node[:example][:group]
  notifies(:restart, resources(:service => "example"))
end

# perform an upgrade if needed

include_recipe "example::hotupgrade"