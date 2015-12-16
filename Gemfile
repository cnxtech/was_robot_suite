source 'https://rubygems.org'

gem 'addressable'
gem 'dor-services', '~> 5.2'
gem 'lyber-core', '~> 3.3.0'
gem 'robot-controller', '~> 2.0.3' # requires Resque
gem 'pry', '~> 0.10.1'     # for bin/console
gem 'slop'  # for bin/run_robot
gem 'rake', '~> 10.3'
gem 'yard'
gem 'rspec'

group :development, :test do
  gem 'coveralls', require: false
  gem 'awesome_print'
end
group :deployment do
  gem 'capistrano-one_time_key'
  gem 'net-ssh-krb'
  gem 'capistrano-bundler'
end
