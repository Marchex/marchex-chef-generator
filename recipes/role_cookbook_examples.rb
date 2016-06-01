puts 'ohai from role_cookbook_cookbook_examples'
context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)
role_json = JSON.parse(File.read(context.role_cookbook_attributes_file))
default_attributes = role_cookbook_json[role_cookbook_json.keys.first]["default_attributes"]
override_attributes = role_cookbook_json[role_cookbook_json.keys.first]["default_attributes"]

require 'pp'
pp context

@@attrs ||= "# Attributes for #{context.cookbook_name} role cookbook\n"

def build_attributes(hash, context=nil)
    current_context ||= ''
    if(context) then
      current_context << "[\"#{context}\"]"
    end
    hash.each do |key, val|
        if val.is_a?(Hash)
            build_attributes(val, key)
        elsif val.is_a?(Array)
            @@attrs << "#{current_context}[\"#{key}\"] = %w( #{val.join(' ')} )\n"
        else
            @@attrs << "#{current_context}[\"#{key}\"] = '#{val}'\n"
        end
    end
end

# Walk attributes data structure and populate it
build_attributes(default_attributes, 'node["default"]')

puts @@attrs

directory "#{cookbook_dir}/attributes/default" do
  recursive true
end

file "#{cookbook_dir}/attributes/default/default.rb" do
  content @@attrs
end
