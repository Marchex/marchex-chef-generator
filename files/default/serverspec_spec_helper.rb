require 'serverspec'

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
  set :backend, :exec
else
  set :backend, :cmd
  set :os, family: 'windows'
end

# Enable 'chain clauses', which makes success/failure messages more explicit.
# For example, given the following test:
#
# describe 5 do
#  it { is_expected.to be_bigger_than(4).and_smaller_than(6) }
# end
#
# The output would look like this:
# "should be bigger than 4"                     # without this setting
# "should be bigger than 4 and smaller than 6"  # with this setting
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
