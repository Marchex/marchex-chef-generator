context = ChefDK::Generator.context
cookbook_dir = File.join(context.cookbook_root, context.cookbook_name)

# Load environment attributes
environment_json = JSON.parse(File.read(context.environment_attributes_file))
if environment_json.has_key?('default_attributes')
  environment_attributes = environment_json['default_attributes']
end
if environment_json.has_key?('override_attributes')
  # Override default attributes with override attributes
  environment_attributes.merge!(environment_json['override_attributes'])
end

@@attrs ||= "# Attributes for #{context.cookbook_name} environment cookbook\n"

def build_attributes(hash, hash_context=nil)
    current_hash_context ||= ''
    if(hash_context) then
      current_hash_context << "[\"#{hash_context}\"]"
    end
    hash.each do |key, val|
        if val.is_a?(Hash)
            build_attributes(val, key)
        elsif val.is_a?(Array)
            @@attrs << "node.force_default#{current_hash_context}[\"#{key}\"] = %w( #{val.join(' ')} )\n"
        else
            @@attrs << "node.force_default#{current_hash_context}[\"#{key}\"] = '#{val}'\n"
        end
    end
end

# def delete_attributes(hash, hash_context=nil)
    # current_hash_context ||= ''
    # if(hash_context) then
      # current_hash_context << "[\"#{hash_context}\"]"
    # end
    # hash.each do |key, val|
        # puts "key: #{key}"
        # if val.is_a?(Hash)
            # delete_attributes(val, key)
        # elsif val.is_a?(Array)
          # puts "key: #{key}"
          # puts "current_hash_context: #{current_hash_context}"
          # puts "context: #{hash_context}"
          # puts "val: #{val}"
        # else
          # puts hash[current_hash_context]
            # @@attrs << "node[\"force_default\"]#{current_hash_context}[\"#{key}\"] = '#{val}'\n"
        # end
    # end
# end

# Migrate from old -> new chef server
def migrate_attributes(environment_attributes)

  # blacklist = {
    # "chef_client" => [ "server_url"],
    # "authconfig" => { "ldap" => { "server" => [ "server_url"] } },
    # "openldap"    => [ "basedn", "ldap_version", "ldap_tls_cacertdir", "server", "server_uri", "tls_cacert" ],
    # "snmp"        => [ "community" ],
    # "sssd_ldap"   => [ "ldap_id_use_start_tls", "ldap_tls_cacertdir", "ldap_tls_reqcert" ]
  # }

  # delete_attributes(blacklist)

  # blacklist.keys.each { |k|
    # blacklist[k].each { |v|
      # puts "deleting #{k}: #{v}"
      # environment_attributes[k].delete(v)
    # }
  # }


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

migrate_attributes(environment_attributes)

# Walk attributes data structure and populate it
build_attributes(environment_attributes)

directory "#{cookbook_dir}/attributes" do
  recursive true
end

file "#{cookbook_dir}/attributes/default.rb" do
  content @@attrs
end
