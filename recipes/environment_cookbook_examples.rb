puts 'ohai!'
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
# data_bag_template_path = File.join(cookbook_dir, "templates", "default", "data_bag_secrets.conf.erb")
# data_bag_example_dir = File.join(cookbook_dir, "test", "integration", "data_bags", context.cookbook_name)
# gemfile_path = File.join(cookbook_dir, "Gemfile")
environment_json = JSON.parse(File.read(context.environment_attributes_file))
environment_attributes = environment_json[environment_json.keys.first]

@attrs ||= "# Attributes for #{context.cookbook_name} environment cookbook\n"

def build_attributes(hash, context=nil)
    current_context ||= 'node["default"]'
    if(context) then
      current_context << "[\"#{context}\"]"
    end
    hash.each do |key, val|
        if val.is_a?(Hash)
            build_attributes(val, key)
        elsif val.is_a?(Array)
            @attrs << "#{current_context}[\"#{key}\"] = %w( #{val.join(' ')} )\n"
        else
            @attrs << "#{current_context}[\"#{key}\"] = '#{val}'\n"
        end
    end
end

# Walk attributes data structure and populate it
build_attributes(environment_attributes)

directory "#{cookbook_dir}/attributes/default" do
  recursive true
end

file "#{cookbook_dir}/attributes/default/default.rb" do
  content @attrs
end
