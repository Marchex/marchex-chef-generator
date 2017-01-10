#!/usr/bin/env ruby
require 'tty-prompt'
require 'mixlib/shellout'
require_relative 'lib/cli'
require_relative 'lib/launch_screen'
require_relative 'lib/migrate'
require_relative 'lib/octo_wrapper'
require_relative 'lib/repository'

puts "Cannot create cookbooks currently, migration in progress"
exit -1
 
launch_screen

# Cookbook type metadata
cookbook_types = {
  custom_cookbook: {
    description:      "a custom, marchex-specific cookbook",
    name_regex:       /^(mchx|foo)_[a-zA-Z_0-9]+$/, # "foo_" for throwaway test cookbooks
    name_hint:        "Clear, short, readable cookbook name (MUST begin with 'mchx_' that others will understand (good: mchx_autobot, bad: mchx_ci_asdfsvc)",
    name_error:       "Must be an alphanumeric word without hyphens, beginning in mchx_." },
  environment_cookbook: {
    description:      "an environment AKA POP cookbook to define attributes (e.g. DNS/LDAP/NTP servers for a POP)",
    name_regex:       /^pop_\w+_\w+$/,
    name_hint:        "Must follow pop_<type>_<location> pattern, e.g. 'pop_di_sea1', 'pop_qa_som1', 'pop_prod_aws_us_west_2_vpc2'.",
    name_error:       "Hint: pop_<type/env>_<location> e.g. pop_prod_som1, pop_qa_aws_us_east_1_vpc3 (no hyphens)." },
  hostclass_cookbook: {
    description:      "a hostclass cookbook to include other recipes and set attributes (e.g. hostclass_vmbuilder includes mchx_ansible and mchx_autobot cookbooks)",
    name_regex:       /^hostclass_[a-zA-Z0-9_]+$/,
    name_hint:        "Clear, short, readable name beginning with hostclass_ that describes what this cookbook will do (good: hostclass_vmbuilder, bad: hostclass_citssvc)",
    name_error:       "Must begin with hostclass_, be alphanumeric, and not include hyphens" },
}

unless check_repo_prerequisites
  exit -1
end

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
elsif (cookbook_type == :hostclass_cookbook)
  if(prompt.ask("Are you migrating from an existing role?", default: 'No', convert: :bool))
    answers[:source_role] = prompt.ask('Enter source role name: ', convert: :string)
    answers[:role_attributes_file] = load_source_role(answers[:source_role])
  end
end

# Give the user a hint as to cookbook naming
prompt.say(cookbook_types[cookbook_type][:name_hint], color: :bright_yellow)

# Get cookbook name and validate that it meets guidelines
cookbook_name = prompt.ask('cookbook name to create: ') do |q|
  q.required true
  q.modify :down, :trim # lowercase input and trim trailing/leading whitespace
  q.validate(cookbook_types[cookbook_type][:name_regex], cookbook_types[cookbook_type][:name_error])
  if answers.has_key?(:source_environment)
    q.default "pop_#{answers[:source_environment].gsub('-','_')}"
  elsif answers.has_key?(:source_role)
    q.default "hostclass_#{answers[:source_role].gsub('role_','').gsub('-','_')}"
  end
end

# Construct command line arguments; first arg is cookbook name, and then key value pairs of attribute=value
generator_options = "#{cookbook_name} "
generator_options << answers.map{ |k,v| "-a #{k}=#{v}" }.join(" ")

generator_command = "chef generate cookbook -g ./skel/ #{generator_options}"
prompt.say("Generating #{cookbook_name} with command '#{generator_command}'\n... please wait ...", color: :bright_green)
shell_command(generator_command)
prompt.say("Cookbook generated successfully in ./#{cookbook_name} directory.", color: :bright_green)

inspec_name = "tests_#{cookbook_name}"
inspec_command = "inspec init profile #{inspec_name}"

unless File.exists?(inspec_name)
  prompt.say("Generating #{inspec_name} with command '#{inspec_command}'\n... please wait ...", color: :bright_green)
  shell_command(inspec_command)
  prompt.say("Test cookbook generated successfully in ./#{inspec_name} directory.", color: :bright_green)
end

# Ask  if they want to create a repo, if they have the required commands/env
@ckbkrepo = MchxChefGen::Repository.new(cookbook_name, 'cookbooks')
@ckbkrepo.init_repo

@inspecrepo = MchxChefGen::Repository.new(inspec_name, 'tests')
@inspecrepo.init_repo

prompt.say("Cookbook initialized! Now, `cd #{@ckbkrepo.get_repodir}` and run 'rake unit' to run tests.
And `cd #{@inspecrepo.get_repodir}` to run and modify integration tests.", color: :bright_green)
