require "bundler/gem_tasks"

require 'rspec/core/rake_task'
require File.expand_path('../lib/marklogic/version', __FILE__)

RSpec::Core::RakeTask.new

task :default => :spec

desc 'Builds the gem'
task :build do
  sh "gem build marklogic.gemspec"
end

desc 'Builds and installs the gem'
task :install => :build do
  sh "gem install marklogic-#{MarkMapper::Version}"
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  sh "git tag v#{MarkMapper::Version}"
  sh "git push origin master"
  sh "git push origin v#{MarkMapper::Version}"
  sh "gem push marklogic-#{MarkMapper::Version}.gem"
end
