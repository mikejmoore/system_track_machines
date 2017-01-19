module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
  
  def reset_test_data
    response = post "/test/reset", {}
    
  end
  

  def create_environment(session, account_id)
    environment = environment_hash(account_id)
    response = post "/api/v1/environments/save", {environment: environment, credentials: session[:credentials]}
    expect(response.status).to eq 200
    environment = JSON.parse(response.body)
  end
  
  
  def save_machine(session, machine)
    response = post "/api/v1/machines/save", {machine: machine, credentials: session[:credentials]}
    expect(response.status).to eq 200
    machine = JSON.parse(response.body)
  end
  
  def save_service(session, service)
    response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
    expect(response.status).to eq 200
    service_json = JSON.parse(response.body)
  end  
  
  def add_environment_to_service(session, service, environment)
    response = put "/api/v1/environments/add_to_service", 
      { 
        service_id: service['id'],
        environment_id: environment['id'],
        credentials: session[:credentials]
      }
    expect(response.status).to eq 200
    service = JSON.parse(response.body)
  end
  
  def register_random_user(session)
    user = unregistered_user
    user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
  end

  
end



RSpec.configure do |config|
  config.include ApiHelper, :type=>:api #apply to all spec for apis folder
end