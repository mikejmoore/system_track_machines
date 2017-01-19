# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'docker_rails_app'

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks


desc "Run this app"
task :start => :environment do
  if (ENV['RAILS_ENV'] == 'development')
    exec "rails s -p 4402 Puma"
  elsif (ENV['RAILS_ENV'] == 'production')
    exec "rails s -p 3000 Puma"
  else
    raise "Dont know how to start in for RAILS_ENV of #{ENV['RAILS_ENV']}"
  end
end
