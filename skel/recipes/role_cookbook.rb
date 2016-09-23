context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

directory "#{cookbook_dir}/attributes" do
  recursive true
end

# See if we're migrating from an existing environment
if defined?(context.role_attributes_file)
  # Yes, migrate the environment attributes
  include_recipe 'marchex-chef-generator::migrate_role'
else
  # No, just load the default example attributes
  template "#{cookbook_dir}/attributes/default.rb" do
    source 'attributes_role_example.rb.erb'
    helpers(ChefDK::Generator::TemplateHelper)
    action :create_if_missing
  end
end

# overwrite default recipe with environment-specific one.
template "#{cookbook_dir}/recipes/default.rb" do
  source "recipe_role.rb.erb"
  helpers(ChefDK::Generator::TemplateHelper)
end
