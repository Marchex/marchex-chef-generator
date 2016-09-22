# marchex-chef-generator
Create skeletons of recipes/cookbooks/etc. that include Marchex-specific patterns/code/etc.

# creating a new cookbook
Run 
```
`./create_cookbook.rb`
```

# Migrating an existing environment or role
1. First, acquire the readonly.pem chef key from the Tools team and place it in ~/.chef/readonly.pem
2. Run `./create_cookbook.rb` and follow the prompts, selecting environment/role cookbook and 'yes' when prompted to migrate an existing environment/role, then follow the prompts.

# Refreshing a Delivery token
```
delivery token --ent marchex --user $USER --server delivery.marchex.com --verify
```