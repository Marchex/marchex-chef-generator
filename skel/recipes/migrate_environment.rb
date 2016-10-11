context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

require_relative '../../lib/migrate.rb'

# Load attributes and run list from passed in environment JSON
environment_attributes = load_attributes(context.environment_attributes_file)

@@attrs ||= "# Attributes for #{context.cookbook_name} environment cookbook\n"

def build_attributes(hash, context=nil)
  current_context ||= ''
  current_context << "['#{context}']" if context
  hash.each do |key, val|
    if val.is_a?(Hash)
      build_attributes(val, key)
    elsif val.is_a?(Array)
      @@attrs << "set_array_attribute( 'force_default', \"#{current_context}['#{key}']\",\n"
      @@attrs << "%20s %s" % [" ", "[\n"] # 20 spaces, then [ and a newline
      if (val.select{|e| e.is_a?(Hash) } != []) # Returns any entries in the array that are Hashes, otherwise an empty array
        @@attrs << "#{val.map{|v| "%22s %s" % [" ", "#{v}" ] }.join(",\n")}\n" # 22 spaces, then the hash values
      else
        @@attrs << "#{val.map{|v| "%22s %s" % [" ", "\"#{v}\"" ] }.join(",\n")}\n" # 22 spaces, then the array values
      end
      @@attrs << "%20s %s" % [" ", "])\n"] # 20 spaces, then ]) and a newline
    else
      @@attrs << "node.force_default#{current_context}['#{key}'] = '#{val}'\n"
    end
  end
end

# Migrate from old -> new chef server
def migrate_attributes(environment_attributes)

  # These are set the same everywhere or not needed -- delete them
  environment_attributes['snmp'].delete('community')
  environment_attributes['chef_client'].delete('server_url')
  environment_attributes['authconfig']['ldap'].delete('server')
  environment_attributes['openldap'].delete('basedn')
  environment_attributes['openldap'].delete('ldap_version')
  environment_attributes['openldap'].delete('ldap_tls_cacertdir')
  environment_attributes['openldap'].delete('server')
  environment_attributes['openldap'].delete('server_uri')
  environment_attributes['openldap'].delete('tls_cacert')
  environment_attributes['sssd_ldap'].delete('ldap_tls_cacertdir')
  environment_attributes['sssd_ldap'].delete('ldap_id_use_start_tls')
  environment_attributes['sssd_ldap'].delete('ldap_tls_reqcert')

  # Transform ['sssd_ldap']['ldap_uri'] to the new ['mchx-auth']['ldap_servers'] attribute
  environment_attributes['mchx-auth'] ||= {}
  environment_attributes['mchx-auth']['ldap_servers'] = environment_attributes['sssd_ldap'].delete('ldap_uri').split(',').map { |s| s.gsub('ldaps://', '') }
end

# Transform/remove existing attributes
migrate_attributes(environment_attributes)

# Walk attributes data structure and populate it
build_attributes(environment_attributes)

file "#{cookbook_dir}/attributes/default.rb" do
  content @@attrs
end
