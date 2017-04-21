#!/usr/bin/env ruby
require 'tty-prompt'
require 'mixlib/shellout'
require_relative 'lib/cli'
require_relative 'lib/launch_screen'
require_relative 'lib/migrate'
require_relative 'lib/octo_wrapper'
require_relative 'lib/repository'

# this updates an existing cookbook to the proper things

launch_screen

unless check_github_token && check_repo_updated
  exit -1
end

# Allow autovivification of hash
answers = Hash.new { |h, k| h[k] = { } }

# Create prompt for collecting input
prompt = TTY::Prompt.new

# Get cookbook name
cookbook_name = ARGV[0]
if !cookbook_name
  cookbook_name = prompt.ask('cookbook name to update: ') do |q|
    q.required true
    q.modify :down, :trim # lowercase input and trim trailing/leading whitespace
  end
end

@ckbkrepo = MchxChefGen::Repository.new(cookbook_name)
@ckbkrepo.update_repo

prompt.say("Cookbook updated! Head to #{@ckbkrepo.get_repourl} to see it.", color: :bright_green)
