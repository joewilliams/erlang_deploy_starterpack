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

# download the upgrade tarball to the right place

remote_file "#{node[:example][:path]}/releases/example_#{node[:example][:version]}.tar.gz" do
  source "#{node[:example][:repo_url]}/upgrades/example_#{node[:example][:version]}.tar.gz"
  owner node[:example][:user]
  group node[:example][:group]
  not_if "/usr/bin/test -d #{node[:example][:path]}/releases/#{node[:example][:version]}"
end

# unpack the tarball

unpack_code = <<-EOH
{ok, _} = release_handler:unpack_release("example_#{node[:example][:version]}").
EOH

erl_call "unpack example" do
  node_name "example@#{node[:fqdn]}"
  name_type "name"
  cookie node[:example][:cookie]
  code unpack_code
  not_if "/usr/bin/test -d #{node[:example][:path]}/releases/#{node[:example][:version]}"
end

# apply any config changes

template "#{node[:example][:path]}/releases/#{node[:example][:version]}/sys.config" do
  source "config.erb"
  owner node[:example][:user]
  group node[:example][:group]
  mode 0644
end

# apply any vm.args changes

template "#{node[:example][:path]}/releases/#{node[:example][:version]}/vm.args" do
  source "vm.args.erb"
  owner node[:example][:user]
  group node[:example][:group]
  mode 0644
end

# upgrade the release

upgrade_code = <<-EOH
{ok, _, _} = release_handler:install_release("#{node[:example][:version]}"),
ok = release_handler:make_permanent("#{node[:example][:version]}").
EOH

erl_call "upgrade example" do
  node_name "example@#{node[:fqdn]}"
  name_type "name"
  cookie node[:example][:cookie]
  code upgrade_code
  not_if do
      (`cat #{node[:example][:path]}/releases/start_erl.data`.include?(node[:example][:version]))
  end
end