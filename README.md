# chefdk-generator
Create skeletons of recipes/cookbooks/etc. that include Marchex-specific improvements.

To use, run `./create_cookbook.rb`

To use, put the following lines at the bottom of your ~/.chef/knife.rb file and replace the `path/to/repo` with the location where you checked out this repo:

```ruby
# knife.rb
# <existing contents>

chefdk.generator_cookbook "path/to/repo"
```
