source 'https://rubygems.org'

# Specify your gem's dependencies in marklogic.gemspec
gemspec

group :development do
  gem 'guard'
  gem 'rspec-nc'

  gem 'pry', :group => :test
  gem 'pry-byebug', :group => :test
  if RUBY_VERSION > '1.9'
    # gem 'rb-fchange', :require => false # Windows
    # gem 'rb-fsevent', :require => false # OS X
    # gem 'rb-inotify', :require => false # Linux
    gem 'terminal-notifier-guard'

    # gem 'guard-bundler'
    gem 'guard-rspec'
    # gem 'guard-jruby-rspec', :platforms => :jruby
    gem 'guard-yard'
  end

  # gem 'ruby-prof', :platforms => :mri
  # gem 'pry-rescue'
  # gem 'pry-nav'
end
