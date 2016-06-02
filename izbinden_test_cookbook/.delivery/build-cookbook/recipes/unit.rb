#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

chef_gem "net_ldap" do
  package_name 'net-ldap'
  version '= 0.12.1'
  compile_time true if Chef::Resource::ChefGem.instance_methods(false).include?(:compile_time)
  action :nothing
end.run_action(:install)  # install at compile time to avoid Last3 library requiring 'net-ldap' before it's installed
                          # see https://tickets.opscode.com/browse/CHEF-3696

include_recipe 'delivery-truck::unit'
