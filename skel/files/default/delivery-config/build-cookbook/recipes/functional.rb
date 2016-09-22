#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::functional'

# if node['delivery']['change']['stage'] == 'acceptance'
  # delivery_test_kitchen 'functional' do
    # yaml '.kitchen.ec2.yml'
    # driver 'ec2'
    # action [:converge, :verify, :destroy]
  # end
# end
