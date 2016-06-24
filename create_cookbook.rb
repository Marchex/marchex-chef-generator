#!/usr/bin/env ruby
require 'tty-prompt'
require 'mixlib/shellout'
require 'pp'

def check_repo_prerequisites
  required_commands = %w( hub github_protect_branch )
  required_commands.each { |c|
    command_check = Mixlib::ShellOut.new("which #{c}").run_command
    if(command_check.exitstatus != 0)
      puts "Missing required command #{c}"
      return false
    end
  }
  return true
end

def shell_command(command, cwd=nil)
  puts "Running command: #{command}"
  cmd = Mixlib::ShellOut.new(command, :cwd => cwd)
  cmd.run_command
  cmd.error! # Display stdout if exit code was non-zero
end

cookbook_types = {
  custom: {
      description:      "a custom, marchex-specific cookbook",
      name_regex:       /.*/,
      name_hint:        "Clear, short, readable cookbook name that others will understand (good: 'autobot', bad: 'ci-asdfsvc')",
      name_error:       "Must be a word." },
    environment: {
      description:      "An environment cookbook to define attributes (e.g. DNS/LDAP/NTP servers for a POP)",
      name_regex:       /^pop_\w+-\w+$/,
      name_hint:        "Must follow pop_<type>-<location> pattern, e.g. 'pop_di-sea1', 'pop_qa-som1', 'pop_prod-aws-us-west-2-vpc2'.",
      name_error:       "Hint: pop_<type/env>-<location> e.g. pop_prod-som1, pop_qa-aws-us-east-1-vpc3." },
    role: {
      description:      "a role cookbook to include other recipes and set attributes (e.g. role_vmbuilder includes ansible and autobot cookbooks)",
      name_regex:       /^role_\w+/,
      name_hint:        "Clear, short, readable name beginning with role_ that describes what this cookbook will do (good: role_vmbuilder, bad: 'role_citssvc')",
      name_error:       "Must begin with role_." },
}


# Allow autovivification of hash
answers = Hash.new { |h, k| h[k] = { } }

# Create prompt for collecting input
prompt = TTY::Prompt.new

puts "Please choose from the following types of cookbooks:\n\n"
cookbook_types.each{ |name,metadata| puts "#{name} - #{metadata[:description]}" }
puts "\n"

# Find cookbook type
cookbook_type = prompt.select("Cookbook type: ", cookbook_types.keys, convert: :string)

# ask if they want chef-vault examples
if (cookbook_type == :custom)
  answers[:include_chef_vault_examples] = prompt.ask('Include chef-vault examples (for rendering sensitive data e.g. passwords/private keys)?', default: false, convert: :bool)
end

# Give the user a hint as to cookbook naming
prompt.say(cookbook_types[cookbook_type][:name_hint], color: :bright_yellow)

# Get cookbook name and validate that it meets guidelines
cookbook_name = prompt.ask('cookbook name: ') do |q|
  q.required true
  q.validate(cookbook_types[cookbook_type][:name_regex], cookbook_types[cookbook_type][:name_error])
  q.modify :down, :trim
end

pp answers

# Construct command line arguments; first arg is cookbook name, and then key value pairs of attribute=value
generator_options = "#{cookbook_name} -- "
generator_options << answers.map{ |k,v| "-a #{k}=#{v}" }.join(" ")

generator_command = "chef generate cookbook -g . #{generator_options}"
prompt.say("Generating #{cookbook_name} with command '#{generator_command}'\n... please wait ...", color: :bright_green)
shell_command(generator_command)

prompt.say("Cookbook generated successfully in ./#{cookbook_name} directory.", color: :bright_green)

unless check_repo_prerequisites
  prompt.say("Can't proceed with repo creation and initialization due to missing commands.", color: :bright_red)
else
  if (prompt.yes?("Initialize repo on https://github.marchex.com/marchex-chef/#{cookbook_name}?"))
    shell_command("git init #{cookbook_name}")
    shell_command("hub create marchex-chef/#{cookbook_name}", cookbook_name)
    shell_command("git add .", cookbook_name)
    shell_command("git commit -m 'Initial commit.'", cookbook_name)
    shell_command("git push origin master", cookbook_name)
    sleep(3)
    # shell_command("cd #{cookbook_name} && git remote add origin https://")
    shell_command("github_protect_branch -o marchex-chef -r #{cookbook_name} -s 'chef_delivery/verify/lint' -s 'chef_delivery/verify/syntax' -s 'chef_delivery/verify/unit' -u chef-delivery")
  end
end

prompt.say("Repo initialized! Now, 'cd #{cookbook_name}' and run 'rake unit' to run tests.", color: :bright_green)

# prompt.say("Now, 'cd #{cookbook_name}' and run 'rake unit' to run tests.", color: :bright_green)
