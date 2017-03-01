require_relative 'repository'

# Check that we have what we need to create/modify git repo
def check_repo_prerequisites
  check_required_commands or return false
  check_github_token or return false

  return true
end

def check_required_commands
  required_commands = %w( curl )
  required_commands.each { |c|
    command_check = Mixlib::ShellOut.new("which #{c}").run_command
    if(command_check.exitstatus != 0)
      puts "Missing required command #{c}"
      return false
    end
  }

  return true
end

def check_github_token
  unless ENV['GITHUB_TOKEN']
    puts "GITHUB_TOKEN environment variable not set - can't proceed with repository creation."
    return false
  end

  return true
end

# Run command and display stdout/stderr if exit code is not zero
# pass in cwd if you want the command to be executed somewhere other than the current directory
def shell_command(command, cwd=nil)
  puts "Running command: #{command}"
  cmd = Mixlib::ShellOut.new(command, :cwd => cwd)
  cmd.run_command
  cmd.error! # Display stdout if exit code was non-zero
  cmd.exitstatus
end

