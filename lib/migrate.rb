require 'json'

def load_attributes(json_file)
  # Load JSON
  parsed_json = JSON.parse(File.read(json_file))
  attributes ||= {}
  # Merge default and override attributes
  if parsed_json.has_key?('default_attributes')
    attributes = parsed_json['default_attributes']
  end
  if parsed_json.has_key?('override_attributes')
    # Override default attributes with override attributes
    attributes.merge!(parsed_json['override_attributes'])
  end

  return attributes
end

def get_role_run_list(json_file)
  # Load JSON
  parsed_json = JSON.parse(File.read(json_file))
  role_run_list = nil
  # Build and return run list
  if parsed_json.has_key?('run_list')
    role_run_list = parsed_json['run_list']
  end

  return role_run_list
end

def parse_run_list_item(item)
  metadata = {
    cookbook_name:    nil,
    recipe_name:      'default',
    cookbook_version: nil
  }

  ### TODO decide whether to use one regex (like here, commented out) or stick with three separate ones (currently in use)
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
