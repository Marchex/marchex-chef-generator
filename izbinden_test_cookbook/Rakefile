# require "bundler/setup"

task :default => [:list]

desc "Lists all the tasks."
task :list do
    puts "Tasks: \n- #{Rake::Task.tasks.join("\n- ")}"
end

desc "Checks for required dependencies."
task :check do
  sh "bundle check"
end

desc "Runs chefspec tests."
task :chefspec do
    sh "rspec spec"
end

desc "Runs kitchen tests."
task :kitchen do
    sh "kitchen test"
end

desc "Runs foodcritic."
task :foodcritic do
    sh "foodcritic . -I ./foodcritic_rules.rb"
end

desc "Runs rubocop."
task :rubocop do
    sh "rubocop ."
end

desc "Run validation tests."
task :lint do
  Rake::Task[:foodcritic].execute
  Rake::Task[:rubocop].execute
end

desc "Run unit tests."
task :unit do
  Rake::Task[:lint].execute
  Rake::Task[:chefspec].execute
end

desc "Run integration tests."
task :integration do
  Rake::Task[:chefspec].execute
  Rake::Task[:kitchen].execute
end
