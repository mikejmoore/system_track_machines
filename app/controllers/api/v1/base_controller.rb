require_relative "../../application_controller"

class Api::V1::BaseController < ApplicationController
  before_action :authenticate_token
  before_action :find_user
  
  
end