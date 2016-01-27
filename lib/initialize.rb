puts "Initializing custom Marchex chef generator..."
generator_dir = File.dirname(__FILE__)
Dir.chdir(generator_dir) {
  update_repo_command = "git pull --rebase 2>&1"
  update_repo_command_output = `#{update_repo_command}`
  unless ($?.success?)
    raise     "'#{update_repo_command}' failed with exit code #{$?.exitstatus} and output:\n\n#{update_repo_command_output}\n" \
          <<  "Please fix this error and re-run the command."
  end
}

Chef::Config[:knife][:vault_admins] = Chef::Knife.new.rest.get_rest("groups/admins")["users"].reject{|u| u == 'pivotal'}

require "#{generator_dir}/launch_screen.rb"

launch_screen
prompt_for_options
