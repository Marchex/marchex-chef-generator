require_relative 'repository'

# make sure in proper directory
Dir.chdir( File.expand_path(File.dirname(__FILE__) + '/..') )

# Check that we have what we need to create/modify git repo
def check_repo_prerequisites
  check_required_commands or return false
  check_github_token or return false
  check_repo_updated or return false

  return true
end

def check_repo_updated
  repo = 'marchex-chef-generator'
  # get remote's master/HEAD sha
  remote_sha = MchxChefGen.get_ref(ENV['GITHUB_TOKEN'], repo, 'heads/master').object.sha
  # get local branches whose HEAD contains sha
  sha_contained = Mixlib::ShellOut.new("git branch --contains #{remote_sha}").run_command

  # sha not found
  if sha_contained.error!
    puts "Remote #{repo} repository has been been changed. Update local repository before continuing."
    exit -1
  # sha exists locally, but not in the HEAD of the current branch
  elsif sha_contained.stdout !~ /^\* /
    puts "Local branch does not include latest code from remote #{repo} repository. Rebase or merge local repository before continuing."
    exit -1
  end

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

