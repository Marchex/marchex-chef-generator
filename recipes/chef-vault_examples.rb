
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
data_bag_template_path = File.join(cookbook_dir, "templates", "default", "data_bag_secrets.conf.erb")
data_bag_example_dir = File.join(cookbook_dir, "test", "integration", "data_bags", context.cookbook_name)
gemfile_path = File.join(cookbook_dir, "Gemfile")

directory "#{cookbook_dir}/templates/default" do
  recursive true
end

cookbook_file data_bag_template_path do
  action :create_if_missing
end

directory data_bag_example_dir do
  recursive true
end

cookbook_file "#{data_bag_example_dir}/database_credentials.json" do
  source 'chef-vault_example_contents.json'
  action :create_if_missing
end

cookbook_file gemfile_path do
  source 'Gemfile_chef-vault-fixtures'
  action :create_if_missing
end
