# marchex-chef-generator
Create skeletons of recipes/cookbooks/etc. that include Marchex-specific patterns/code/etc.

# Install development kit
Please install [mchx_dk](https://github.marchex.com/marchex-chef/mchx_dk) first.

# Token
You need to use an API token (set in `GITHUB_TOKEN` environment variable) with the "repo" and "admin:pre_receive_hook" [scopes](https://github.marchex.com/settings/tokens) set.

# Creating a new cookbook
Run 
```
`./create_cookbook.rb`
```

This script **must** be used for creating new cookbooks.  It does a lot for us, including (but not limited to):
* Creates cookbook with the right name, files, and content (and there's a lot)
* Creates repo in GitHub
* Sets up branch protection and other settings in GitHub
* Pushes repo to GitHub
* Creates and sets up inspec test repo

# Updating a new cookbook
To update an existing cookbook's GitHub settings for branch protection, run
```
`./update_cookbook.rb`
```

# Migrating an existing environment or role
1. First, acquire the readonly.pem chef key from the Tools team and place it in ~/.chef/readonly.pem
2. Run `./create_cookbook.rb` and follow the prompts, selecting environment/role cookbook and 'yes' when prompted to migrate an existing environment/role, then follow the prompts.
