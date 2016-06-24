context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

# Load role attributes from 'source' role (if specified)
role_json = JSON.parse(File.read(context.role_attributes_file))
role_attributes ||= {}
if role_json.has_key?('default_attributes')
  role_attributes = role_json['default_attributes']
end
if role_json.has_key?('override_attributes')
  # Override default attributes with override attributes
  role_attributes.merge!(role_json['override_attributes'])
end

role_run_list = nil
if role_json.has_key?('run_list')
  role_run_list = role_json['run_list']
end

@@attrs ||= "# Attributes for #{context.cookbook_name} role cookbook\n"

def build_attributes(hash, context=nil)
  current_context ||= ''
  current_context << "['#{context}']" if context
  hash.each do |key, val|
      if val.is_a?(Hash)
          build_attributes(val, key)
      elsif val.is_a?(Array)
        @@attrs << "set_array_attribute( 'normal', \"#{current_context}['#{key}']\", [\n\t\t"
        @@attrs << "#{val.map{|v| "\"#{v}\"" }.join(",\n\t\t")}"
        @@attrs << "\n\t]\n"
      else
          @@attrs << "node.normal#{current_context}[\"#{key}\"] = '#{val}'\n"
      end
  end
end

def parse_run_list_item(item)
  metadata = {
    cookbook_name:    nil,
    recipe_name:      'default',
    cookbook_version: nil
  }

  # Pull apart run list item to get its component parts (1 to 3 items:
  # $1: name of cookbook or role -- REQUIRED
  # $2: name of recipe -- OPTIONAL, defaults to 'default'
  # $3: version of cookbook -- OPTIONAL, defaults to nil
  # Example inputs/outputs:
  # "recipe[ciCommon::default@0.2.0]" --> ciCommon, default,  0.2.0
  # "recipe[diamond@1.0.24]",         --> diamond,  default,  1.0.24
  # "recipe[foo]",                    --> foo,      default,  nil
  # "recipe[foo::default]",           --> foo,      default,  nil
  # "role[bar]"                       --> role_bar
  # if(item =~ /\[(.*?)(?:\:\:(.*?))?(?:\@(.*))?\]/)
    # puts "$1: #{$1}, $2: #{$2}, $3: #{$3}"
  # end

  # Store cookbook name
  # recipe[foo]             --> foo
  # recipe[foo::bar]        --> foo
  # recipe[foo::bar@0.1.0]  --> foo
  metadata[:cookbook_name] = item.match(/\[(.*?)(?:\:\:.*)?(?:\@.*)?\]/).captures[0]

  # Store recipe name
  # recipe[foo::bar]        --> bar
  # recipe[foo::bar@0.1.0]  --> bar
  if(item.match(/\:\:/))
     metadata[:recipe_name] = item.match(/\:\:(.*?)(?:\@.*)?\]/).captures[0]
  end

  # Store cookbook version
  # recipe[foo]             --> nil
  # recipe[foo::bar]        --> nil
  # recipe[foo::bar@0.1.0]  --> 0.1.0
  if(item.match(/\@/))
    metadata[:cookbook_version] = item.match(/@(.*)\]/).captures[0]
  end

  return metadata
end

@@role_cookbook_dependencies ||= []

def build_run_list(rl=nil)
  rl.each { |item|
    @@role_cookbook_dependencies << parse_run_list_item(item.sub('role[','recipe[role_'))
  }
end

# Walk attributes data structure and populate it
build_attributes(role_attributes)
build_run_list(role_run_list)

file "#{cookbook_dir}/attributes/default.rb" do
  content @@attrs
end

# Add dependencies to context for rendering metadata.rb and include_recipe lines in recipes/default.rb
ChefDK::Generator.add_attr_to_context(:role_cookbook_dependencies, @@role_cookbook_dependencies)
