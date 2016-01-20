# chefdk-generator
Create skeletons of recipes/cookbooks/etc. that include Marchex-specific improvements.

To use, run `chef generate cookbook <my-cookbook-name>`

To use, put the following lines at the bottom of your ~/.chef/knife.rb file and replace the <path/to/repo> with the location where you checked out this repo:

```ruby
# knife.rb
# <existing contents>
custom_generator          "<path/to/repo>"

if Dir.exists?(custom_generator)
  # Load custom generator
  chefdk.generator_cookbook custom_generator
  if defined?(ChefDK::CLI) && ARGV.include?('generate')
    require "#{chefdk.generator_cookbook}/lib/initialize.rb"
  end
end 
```
