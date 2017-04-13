
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

# cookbook root dir
directory cookbook_dir

# metadata.rb
template "#{cookbook_dir}/metadata.rb" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# README
template "#{cookbook_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# INSTALL
template "#{cookbook_dir}/LICENSE" do
  source "LICENSE.all_rights.erb"
  helpers(ChefDK::Generator::TemplateHelper)
end

# chefignore
cookbook_file "#{cookbook_dir}/chefignore"

# Berks
cookbook_file "#{cookbook_dir}/Berksfile" do
  action :create_if_missing
end

# Gemfile
cookbook_file "#{cookbook_dir}/Gemfile" do
  action :create_if_missing
end

# Jenkinsfile
cookbook_file "#{cookbook_dir}/Jenkinsfile" do
  action :create_if_missing
end

# Rakefile
cookbook_file "#{cookbook_dir}/Rakefile"
cookbook_file "#{cookbook_dir}/base.rake"

# TK & Serverspec
template "#{cookbook_dir}/.kitchen.yml" do
  source 'kitchen.yml.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

template "#{cookbook_dir}/.kitchen.ec2.yml" do
  source 'kitchen.ec2.yml.erb'
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

directory "#{cookbook_dir}/test/shared" do
  recursive true
end

directory "#{cookbook_dir}/test/data_bags" do
  recursive true
end

remote_directory "#{cookbook_dir}/.bundle"

cookbook_file "#{cookbook_dir}/.rubocop.yml" do
  source 'rubocop.yml'
  action :create_if_missing
end

cookbook_file "#{cookbook_dir}/.foodcritic" do
    source "foodcritic"
    action :create_if_missing
end

cookbook_file "#{cookbook_dir}/test/shared/vagrant_cache_omnibus.rb" do
  action :create_if_missing
end


# Chefspec
directory "#{cookbook_dir}/spec/unit/recipes" do
  recursive true
end

template "#{cookbook_dir}/spec/spec_helper.rb" do
  source "spec_helper.rb.erb"
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

template "#{cookbook_dir}/spec/unit/recipes/default_spec.rb" do
  source "recipe_spec.rb.erb"
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# Recipes

directory "#{cookbook_dir}/recipes"

template "#{cookbook_dir}/recipes/default.rb" do
  source "recipe.rb.erb"
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

# git
if context.have_git
  if !context.skip_git_init

    execute("initialize-git") do
      command("git init .")
      cwd cookbook_dir
    end
  end

  cookbook_file "#{cookbook_dir}/.gitignore" do
    source "gitignore"
  end
end

include_recipe 'skel::chef-vault_examples' if ( defined?(context.include_chef_vault_examples) && (context.include_chef_vault_examples == 'true') )
include_recipe 'skel::environment_cookbook' if ( defined?(context.cookbook_type) && (context.cookbook_type == 'environment_cookbook') )
include_recipe 'skel::role_cookbook' if ( defined?(context.cookbook_type) && (context.cookbook_type == 'hostclass_cookbook') )
