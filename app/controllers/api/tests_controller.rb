require_relative "../application_controller"

module Api
  class TestsController < ApplicationController
    
    def reset
      if (ENV['RAILS_ENV'] == "development") || (ENV['RAILS_ENV'] == "test")
        require "database_cleaner"
        DatabaseCleaner.clean_with :truncation
      else
        raise "Cannot set up test data in production"
      end
      render text: "{}"
    end

  end
    
end