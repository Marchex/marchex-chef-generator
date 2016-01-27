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
# Load vault_admins for vault commands
Chef::Config[:knife][:vault_admins] = Chef::Knife.new.rest.get_rest("groups/admins")["users"].reject{|u| u == 'pivotal'}
