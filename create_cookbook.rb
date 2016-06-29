#!/usr/bin/env ruby
require 'tty-prompt'
require 'mixlib/shellout'
require_relative 'lib/launch_screen.rb'
require_relative 'lib/migrate.rb'

launch_screen

# Check that we have what we need to create/modify git repo
def check_repo_prerequisites
  unless ENV['MARCHEX_GITHUB_TOKEN']
    puts "MARCHEX_GITHUB_TOKEN environment variable not set - can't proceed with repository creation."
    return false
  end

  required_commands = %w( hub github_protect_branch curl )
  required_commands.each { |c|
    command_check = Mixlib::ShellOut.new("which #{c}").run_command
    if(command_check.exitstatus != 0)
      puts "Missing required command #{c}"
      return false
    end
  }
  return true
end

# Run command and display stdout/stderr if exit code is not zero
# pass in cwd if you want the command to be executed somewhere other than the current directory
def shell_command(command, cwd=nil)
  puts "Running command: #{command}"
  cmd = Mixlib::ShellOut.new(command, :cwd => cwd)
  cmd.run_command
  cmd.error! # Display stdout if exit code was non-zero
end

# Cookbook type metadata
cookbook_types = {
  custom_cookbook: {
    description:      "a custom, marchex-specific cookbook",
    name_regex:       /.*/,
    name_hint:        "Clear, short, readable cookbook name that others will understand (good: autobot, bad: ci-asdfsvc)",
    name_error:       "Must be a word." },
  environment_cookbook: {
    description:      "an environment AKA POP cookbook to define attributes (e.g. DNS/LDAP/NTP servers for a POP)",
    name_regex:       /^pop_\w+-\w+$/,
    name_hint:        "Must follow pop_<type>-<location> pattern, e.g. 'pop_di-sea1', 'pop_qa-som1', 'pop_prod-aws-us-west-2-vpc2'.",
    name_error:       "Hint: pop_<type/env>-<location> e.g. pop_prod-som1, pop_qa-aws-us-east-1-vpc3." },
  role_cookbook: {
    description:      "a role cookbook to include other recipes and set attributes (e.g. role_vmbuilder includes ansible and autobot cookbooks)",
    name_regex:       /^role_\w+/,
    name_hint:        "Clear, short, readable name beginning with role_ that describes what this cookbook will do (good: role_vmbuilder, bad: role_citssvc)",
    name_error:       "Must begin with role_." },
}


# Allow autovivification of hash
answers = Hash.new { |h, k| h[k] = { } }

# Create prompt for collecting input
prompt = TTY::Prompt.new

# Find out which type of cookbook they want
puts "Please choose from the following types of cookbooks:\n\n"
cookbook_types.each{ |name,metadata| puts "#{name}".ljust(15) << "- #{metadata[:description]}".ljust(10) }
puts "\n"

# Find cookbook type
cookbook_type = answers[:cookbook_type] = prompt.select("Cookbook type: ", cookbook_types.keys, convert: :string)

# Ask if they want chef-vault examples
if (cookbook_type == :custom_cookbook)
  answers[:include_chef_vault_examples] = prompt.ask('Include chef-vault examples? (Useful for handling sensitive data e.g. passwords/private keys)', default: 'No', convert: :bool)
elsif (cookbook_type == :environment_cookbook)
  if(prompt.ask("Are you migrating from an existing environment?", default: 'No', convert: :bool))
    answers[:source_environment] = prompt.ask('Enter source environment name: ', convert: :string)
    answers[:environment_attributes_file] = load_source_environment(answers[:source_environment])
  end
elsif (cookbook_type == :role_cookbook)
  if(prompt.ask("Are you migrating from an existing role?", default: 'No', convert: :bool))
    answers[:source_role] = prompt.ask('Enter source role name: ', convert: :string)
    answers[:role_attributes_file] = load_source_role(answers[:source_role])
  end
end

# Give the user a hint as to cookbook naming
prompt.say(cookbook_types[cookbook_type][:name_hint], color: :bright_yellow)

# Get cookbook name and validate that it meets guidelines
cookbook_name = prompt.ask('cookbook name: ') do |q|
  q.required true
  q.modify :down, :trim # lowercase input and trim trailing/leading whitespace
  q.validate(cookbook_types[cookbook_type][:name_regex], cookbook_types[cookbook_type][:name_error])
  if answers.has_key?(:source_environment)
    q.default "pop_#{answers[:source_environment]}"
  elsif answers.has_key?(:source_role)
    q.default "role_#{answers[:source_role]}"
  end
end

# Construct command line arguments; first arg is cookbook name, and then key value pairs of attribute=value
generator_options = "#{cookbook_name} "
generator_options << answers.map{ |k,v| "-a #{k}=#{v}" }.join(" ")

generator_command = "chef generate cookbook -g . #{generator_options}"
prompt.say("Generating #{cookbook_name} with command '#{generator_command}'\n... please wait ...", color: :bright_green)
shell_command(generator_command)

prompt.say("Cookbook generated successfully in ./#{cookbook_name} directory.", color: :bright_green)

# Ask if they want to create a repo, if they have the required commands/env
unless check_repo_prerequisites
  prompt.say("Can't proceed with repo creation and initialization due to missing prerequisites.", color: :bright_red)
else
  repo_url = "https://github.marchex.com/marchex-chef/#{cookbook_name}"
  # See if repo already exists
  prompt.say("Checking to see whether #{repo_url} already exists...", color: :bright_yellow)
  repo_check_http_code =  Mixlib::ShellOut.new("curl -IsS -o /dev/null --connect-timeout 3 -w '%\{http_code\}' #{repo_url}").run_command.stdout
  if (repo_check_http_code != "404")
    prompt.say("repository already exists at #{repo_url} -- not creating/modifying it.", color: :bright_yellow)
  elsif(prompt.yes?("Initialize repo at #{repo_url}?"))
    shell_command("git init #{cookbook_name}")
    shell_command("hub create marchex-chef/#{cookbook_name}", cookbook_name)
    shell_command("git add .", cookbook_name)
    shell_command("git commit -m 'Initial commit.'", cookbook_name)
    shell_command("git push origin master", cookbook_name)
    # Running github_protect_branch immediately after the initial push fails sometimes, so sleep for 3 seconds
    sleep(3)
    # Set up master branch protection rules
    shell_command("github_protect_branch -o marchex-chef -r #{cookbook_name} -s 'chef_delivery/verify/lint' -s 'chef_delivery/verify/syntax' -s 'chef_delivery/verify/unit' -u chef-delivery")
  end
end

prompt.say("Cookbook initialized! Now, 'cd #{cookbook_name}' and run 'rake unit' to run tests.", color: :bright_green)
