

class ApplicationController < ActionController::Base
  include SystemTrack::ApplicationControllerModule
  before_action :authenticate_token
  before_action :find_user
  before_action :destroy_session
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from SystemTrack::TokenAuthException, with: :token_auth_error
  rescue_from SystemTrack::NotAuthenticatedException, with: :token_auth_error
  rescue_from SystemTrack::NotAuthorizedException, with: :not_authorized
  
  
  rescue_from Exception do |exception|
    api_exception_handler(exception)
  end  
  
end
