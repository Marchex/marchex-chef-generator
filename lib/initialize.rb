puts "Initializing custom Marchex chef generator..."

generator_dir = File.dirname(__FILE__)
update_repo_command = "git -C #{generator_dir} pull --rebase 2>&1"
update_repo_command_output = `#{update_repo_command}`
# unless ($?.success?)
  # raise     "'#{update_repo_command}' failed with exit code #{$?.exitstatus} and output:\n\n#{update_repo_command_output}\n" \
        # <<  "Please fix this error and re-run the command."
# end

require "#{generator_dir}/launch_screen.rb"

launch_screen
prompt_for_options

