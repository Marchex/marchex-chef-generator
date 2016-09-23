context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

require_relative '../lib/migrate.rb'

# Load attributes and run list from passed in role JSON
role_attributes = load_attributes(context.role_attributes_file)
role_run_list = get_role_run_list(context.role_attributes_file)

@@attrs ||= "# Attributes for #{context.cookbook_name} role cookbook\n"

def build_attributes(hash, context=nil)
  current_context ||= ''
  current_context << "['#{context}']" if context
  hash.each do |key, val|
    if val.is_a?(Hash)
      build_attributes(val, key)
    elsif val.is_a?(Array)
      @@attrs << "set_array_attribute( 'normal', \"#{current_context}['#{key}']\",\n"
      @@attrs << "%20s %s" % [" ", "[\n"] # 20 spaces, then [ and a newline
      if (val.select{|e| e.is_a?(Hash) } != []) # Returns any entries in the array that are Hashes, otherwise an empty array
        @@attrs << "#{val.map{|v| "%22s %s" % [" ", "#{v}" ] }.join(",\n")}\n" # 22 spaces, then the hash values
      else
        @@attrs << "#{val.map{|v| "%22s %s" % [" ", "\"#{v}\"" ] }.join(",\n")}\n" # 22 spaces, then the array values
      end
      @@attrs << "%20s %s" % [" ", "])\n"] # 20 spaces, then ]) and a newline
    else
      @@attrs << "node.normal#{current_context}['#{key}'] = '#{val}'\n"
    end
  end
end

# Find which cookbooks this role depends on
@@role_cookbook_dependencies ||= []

def build_dependencies(run_list)
  run_list.each { |item|
    # Substitute 'role[<name>]' entries with 'recipe[role_<name>]'
    @@role_cookbook_dependencies << parse_run_list_item(item.sub('role[','recipe[role_'))
  }
end

# Walk attributes data structure and populate it
build_attributes(role_attributes)
build_dependencies(role_run_list)

# Render attributes
file "#{cookbook_dir}/attributes/default.rb" do
  content @@attrs
end

# Add dependencies to context for rendering metadata.rb and include_recipe lines in recipes/default.rb
ChefDK::Generator.add_attr_to_context(:role_cookbook_dependencies, @@role_cookbook_dependencies)
