# TODO: add 'rollup' to roles when ready for multi-level CDX indexing jobs
server 'was-robots1-prod.stanford.edu', user: 'was', roles: %w{web app db monitor}

Capistrano::OneTimeKey.generate_one_time_key!

set :deploy_environment, 'production'
set :whenever_environment, fetch(:deploy_environment)
set :honeybadger_env, fetch(:deploy_environment)
set :default_env, { robot_environment: fetch(:deploy_environment) }
set :bundle_without, %w{deployment development test}.join(' ')
