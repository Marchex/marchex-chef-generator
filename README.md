# marchex-chef-generator
Create skeletons of recipes/cookbooks/etc. that include Marchex-specific improvements.

# creating a new cookbook
Run `./create_cookbook.rb`

# Migrating an existing environment
1. `knife download /environments`
2. `chef generate cookbook -g . <cookbook_name> -a environment_attributes_file='</path/to/environments/<env>.json file>' -a cookbook_type=environment_cookbook`

Example command: `chef generate cookbook -g . pop_prod-sea1 -a environment_attributes_file='../marchex-chef/environments/prod-sea1.json' -a cookbook_type=environment_cookbook`

## Migrating an existing role

1. `knife download /roles`
2. `chef generate cookbook -g . <cookbook_name> -a role_attributes_file='</path/to/roles/<role>.json file>' -a cookbook_type=role_cookbook`

Example command: `chef generate cookbook -g . role_vscron-som1 -a role_attributes_file='../marchex-chef/roles/vscron-som1.json' -a cookbook_type=role_cookbook`
