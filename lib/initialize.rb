require 'chef'
require 'chef/knife'

# Update generator code
generator_dir = File.dirname(__FILE__)
Dir.chdir(generator_dir) {
  update_repo_command = "git pull --rebase 2>&1"
  update_repo_command_output = `#{update_repo_command}`
  unless ($?.success?)
    raise     "'#{update_repo_command}' failed with exit code #{$?.exitstatus} and output:\n\n#{update_repo_command_output}\n" \
          <<  "Please fix this error and re-run the command."
  end
}

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
