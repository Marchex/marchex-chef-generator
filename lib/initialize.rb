require 'chef'
require 'chef/knife'

# Find the latest sha of the generator code and complain if the local copy is out of date
# Comment out until we find a better way to determine whether you have the latest code - 
# git rev-parse @ is only in newer version of git not available in the standard 12.04 apt repo
# generator_dir = "#{File.dirname(__FILE__)}/.."
# Dir.chdir(generator_dir) {
  # current_sha = `git rev-parse @`
  # remote_sha  = `git rev-parse @{u}`
  # unless (current_sha == remote_sha)
    # Chef::Log.warn("### WARNING ### You do not have the latest code checked out, please run 'cd #{generator_dir}' and do a 'git pull'")
  # end
# }

# Always run vault commands in client mode
Chef::Config[:knife][:vault_mode] = 'client'
begin
  # Load vault_admins for vault commands
  Chef::Config[:knife][:vault_admins] = Chef::Knife.new.rest.get_rest("groups/admins")["users"].reject{|u| u == 'pivotal'}
rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
  if e.to_s.include?('403')
    puts "####################################################################################################"
    puts "You're not in the 'admins' group on the chef server. Please send an email to tools-team@marchex.com."
    puts "####################################################################################################"
  end
  raise e
end
