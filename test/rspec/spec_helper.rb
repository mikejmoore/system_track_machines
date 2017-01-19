ENV["RAILS_ENV"] ||= "test"

require_relative "../../config/environment"
require_relative "../../app/models/tag"
  
require 'rspec'
require 'database_cleaner'
require 'random_word'
require 'byebug'
require 'factory_girl'
require_relative "./support/api_helper"

def helper_module_include_type
  #return :request
  return :feature 
end 

include ApiHelper

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
Dir.glob("./test/factories/**/*.rb").each { |f|
  require f
}

def api_setup(user, content_type = 'application/json')
  with_content_type_header content_type
  with_accept_header content_type
end

def not_implemented
  pending("Not Implemented") {
    raise "Not Implemented"
  }
end

def has_matching_attribute?(selector, attribute, value)
  page.all(selector).any? do |elem|
    elem[attribute] =~ value
  end
end



if ENV['REMOTE_SERVER'] != nil
  Capybara.server_host = ENV['REMOTE_SERVER'] #using this to run test on grid2
end

ActionController::Base.class_eval do
  def rescue_action(exception)
    raise exception
  end
end


def truncate_database()
  DatabaseCleaner.clean_with :truncation
  response = SystemTrack::UsersProxy.new.service_connection.post "/test/reset", {}
  raise "Unsuccessful user test data reset" if response.status != 200
end


RSpec.configure do |config|
  config.include LoggingHelper

#  config.mock_with :rspec
  
  config.before :each do
    #WebMock.allow_net_connect!
    puts "Before Scenario...."
  end

  config.before(:suite) do
    puts "Before Suite...."
    truncate_database()
  end
  
  config.before :all do
    truncate_database();
  end
  
  config.after :all do
  end
  
  config.after(:suite) do
#      DatabaseCleaner.clean_with :truncation
  end
  
end