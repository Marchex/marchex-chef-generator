#!/usr/bin/env ruby

require 'json'
require 'pp'

role_json = JSON.parse(File.read(ARGV[0]))
role_name = role_json['name']
role_attributes ||= {}
if role_json.has_key?('default_attributes')
  role_attributes = role_json['default_attributes']
end
if role_json.has_key?('override_attributes')
  # Override default attributes with override attributes
  role_attributes.merge!(role_json['override_attributes'])
end

role_run_list = role_json['run_list']

@attrs ||= "# Attributes for #{role_name} role cookbook\n"

def build_attributes(hash, context=nil)
  current_context ||= ''
  current_context << "['#{context}']"
  hash.each do |key, val|
      if val.is_a?(Hash)
          build_attributes(val, key)
      elsif val.is_a?(Array)
        @attrs << "set_array_attribute( 'normal', \"#{current_context}['#{key}']\" = [ \n\t\t"
        @attrs << "#{val.map{|v| "\"#{v}\"" }.join(",\n\t\t")}"
        @attrs << "\n\t]\n"
      else
          @attrs << "node.normal#{current_context}[\"#{key}\"] = '#{val}'\n"
      end
  end
end

@run_list ||= "# Run list for #{role_name} role cookbook\n"
@cookbook_dependencies ||= "# Dependencies for #{role_name} role cookbook metadata"

def get_recipe_name(recipe)
  # Find and the string between []
  # recipe[foo]             --> foo
  # recipe[foo::bar]        --> foo::bar
  # recipe[foo::bar@0.1.0]  --> foo::bar
  if(recipe.match(/@/))
    puts "WARNING: version pinning detected for #{recipe}\n"
  end

  return recipe.match(/\[(.*)\]/).captures[0]
end

def build_run_list(rl=nil)
  run_list_items = Array.new
  rl.each { |item|
    if item.match("^recipe")
      run_list_items << get_recipe_name(item)
    elsif item.match("^role")
      # Convert to role cookbook name
      # role[vscron-ubuntu] --> recipe[role_vscron-ubuntu]
      run_list_items << get_recipe_name(item.sub('role[','recipe[role_'))
    end
  }

  # Build 'include_recipe' lines and metadata lines
  run_list_items.each{ |rli|
    @run_list << "include_recipe '#{rli}'\n"
  }
end


# Walk attributes data structure and populate it
build_attributes(role_attributes)
# build_attributes(default_attributes, 'force_default')
# build_attributes(default_attributes, 'default')
# build_attributes(override_attributes, 'force_override')
build_run_list(role_run_list)

puts @attrs
puts @run_list
# puts default_attrs
# puts override_attrs
