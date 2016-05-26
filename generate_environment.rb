#!/usr/bin/env ruby

require 'json'

environment_json = JSON.parse(File.read(ARGV[0]))
environment_name = environment_json['name']
if environment_json.has_key?('default_attributes')
  default_attributes = environment_json['default_attributes'].sort.to_h
end
if environment_json.has_key?('override_attributes')
  override_attributes = environment_json['override_attributes'].sort.to_h
end

@attrs ||= "# Attributes for #{environment_name} environment cookbook\n"

def build_attributes(hash, precedence='force_default', context=nil)
  return if hash.nil?
  current_context ||= ''
  current_context << "[\"#{context}\"]"
  hash.each do |key, val|
      if val.is_a?(Hash)
          build_attributes(val, precedence, key)
      elsif val.is_a?(Array)
          @attrs << "#{precedence}#{current_context}[\"#{key}\"] = %w( #{val.join(' ')} )\n"
      else
          @attrs << "#{precedence}#{current_context}[\"#{key}\"] = '#{val}'\n"
      end
  end
end

# Walk attributes data structure and populate it
# build_attributes(default_attributes)
build_attributes(default_attributes, 'force_default')
# build_attributes(default_attributes, 'default')
build_attributes(override_attributes, 'force_override')

puts @attrs
# puts default_attrs
# puts override_attrs
