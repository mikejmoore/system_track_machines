require_relative '../spec_helper'


describe "Services", :type => :api do
  # let!(:user)  { {} }
  # let!(:service)  { FactoryGirl.create :service, account: user.account }
  #
  # let!(:other_account) { FactoryGirl.create :account }
  # let!(:other_service)  { FactoryGirl.create :service, account: other_account }
  
  include SystemTrack
  
  context "Find service information" do
    
    it "Can find my services" do
      session = {}
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
      
      credentials = session[:credentials]
      service_hashes = []
      (1..3).each do
        service = service_hash(user['account_id'])
        service_hashes << service
        response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
        expect(response.status).to eq 200
        service_back = JSON.parse(response.body)
      end
      
      response = get "/api/v1/services/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      services_json = JSON.parse(response.body)
      expect(services_json.length).to eq service_hashes.length
      
      SystemTrack::UsersProxy.new.logoff(session)
      response = get "/api/v1/services/index", {credentials: credentials}
      expect(response.status).to eq 401
    end
    
    
    it "Cannot see other accounts services" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: other_user}))
      (1..2).each do
        service = service_hash(other_user.account_id)
        post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
      end
      
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
      expect(other_user['account_id']).to_not eq user.account_id

      response = get "/api/v1/services/index", {account_id: other_user.account_id, credentials: user.credentials}
      expect(response.status).to eq 403
    end
    
    it "Super user can see any account's services'" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: other_user}))
      (1..2).each do
        service = service_hash(other_user.account_id)
        post "/api/v1/services/save", {service: service, credentials: other_user.credentials}
      end
      
      super_user = UserObject.new(SystemTrack::UsersProxy.new.sign_in(session, SystemTrack::TestConstants::SUPER_USER[:email], SystemTrack::TestConstants::SUPER_USER[:password]))
      response = get "/api/v1/services/index", {account_id: other_user.account_id, credentials: super_user.credentials}
      expect(response.status).to eq 200
      services_json = JSON.parse(response.body)
      expect(services_json.length).to eq 2
    end
    
  end
  
  context "Can change information about services" do
    
    it "Can create a new service" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))

      service_in = service_hash(user.account_id)
      response = post("/api/v1/services/save", {credentials: user.credentials, service: service_in})
      expect(response.status).to eq 200
      return_json = JSON.parse(response.body)
      
      expect(return_json['name']).to eq service_in[:name]
      expect(return_json['code']).to eq service_in[:code]
      expect(return_json['account_id']).to eq user.account_id
      expect(return_json['description']).to eq service_in[:description]
    end
  end

  context "Services reside on machines" do
    
    it "Can add service to a machine" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))
      environment_1 = create_environment(session, user['account_id'])
      environment_2 = create_environment(session, user['account_id'])

      machine = machine_hash(user['account_id'])
      response = post "/api/v1/machines/save", {machine: machine, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machine_json = JSON.parse(response.body)

      service = service_hash(user['account_id'])
      response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
      expect(response.status).to eq 200
      service_json = JSON.parse(response.body)

      service_ip_address = 3400

      response = put("/api/v1/services/add_to_machine", {credentials: user.credentials,
              service_id: service_json['id'],
              machine_id: machine_json['id'],
              environment_id: environment_1['id'],
              ip_address: service_ip_address})
      expect(response.status).to eq 200
      service_json = JSON.parse(response.body)
      machine_service_json = service_json['machine_services'].first
      
      expect(machine_service_json['environment']).to_not be nil
      expect(machine_service_json['environment']['name']).to eq environment_1['name']
      response = delete "/api/v1/services/remove_from_machine", {
        credentials: user.credentials, 
        machine_service_id: machine_service_json['id']
      }
      expect(response.status).to eq 200
      service_json = JSON.parse(response.body)
      expect(service_json['machine_services'].length).to eq 0
    end
    
    
    
    
    it "API allows machines for service inside of service json spec" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))
      
      environment = create_environment(session, user['account_id'])
      
      machine = machine_hash(user['account_id'])
      response = post "/api/v1/machines/save", {machine: machine, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machine_json = JSON.parse(response.body)

      service = service_hash(user['account_id'])
      service[:machine_services] = [
        {machine_id: machine_json['id'], ip_address: machine[:network_cards].first[:ip_address], environment_id: environment['id']}
      ]
      response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
      expect(response.status).to eq 200
      service = JSON.parse(response.body)
      response = put "/api/v1/services/add_to_machine", {service_id: service['id'], machine_id: machine_json['id'], environment_id: environment['id'], credentials: session[:credentials]}
      expect(response.status).to eq 200
      service_json = JSON.parse(response.body)
      expect(service_json['machine_services'].first).to_not be nil
      expect(service_json['machine_services'].first['environment_id']).to eq environment['id']
      expect(service_json['machine_services'].first['machine_id']).to eq machine_json['id']
    end
    
  end
  
  context "Can attach services to environments" do

    it "Can attach and remove environment to service" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))
      environment_1 = create_environment(session, user['account_id'])
      environment_2 = create_environment(session, user['account_id'])

      service = service_hash(user['account_id'])
      response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
      expect(response.status).to eq 200
      service = JSON.parse(response.body)

      response = put "/api/v1/environments/add_to_service", {service_id: service['id'], environment_id: environment_1['id'], credentials: session[:credentials]}
      expect(response.status).to eq 200
      service = JSON.parse(response.body)
      
      expect(service['environments'].length).to eq 1
      expect(service['environments'].first['code']).to eq environment_1['code']
      expect(service['environments'].first['id']).to eq environment_1['id']
      
      response = delete "/api/v1/environments/remove_from_service", {service_id: service['id'], environment_id: environment_1['id'], credentials: session[:credentials]}
      expect(response.status).to eq 200
      service = JSON.parse(response.body)
      
      expect(service['environments'].length).to eq 0
    end
  end
  
  
  context "Networks can host one or more services" do
    it "Can attach a service to a network" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))

      network_in = network_hash(user.account_id)
      response = post("/api/v1/networks/save", {credentials: user.credentials, network: network_in})
      expect(response.status).to eq 200
      network_json = JSON.parse(response.body)

      # Create a couple services and add to network
      service_hashes = []
      (1..2).each do
        service = service_hash(user['account_id'])
        service_hashes << service
        response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
        expect(response.status).to eq 200
        service_json = JSON.parse(response.body)

        response = put("/api/v1/services/add_to_network", {credentials: user.credentials, service_id: service_json['id'], network_id: network_json['id']})
        expect(response.status).to eq 200
        services = JSON.parse(response.body)
        expect(services['networks'].first['id']).to eq network_json['id']
      end
    end

    it "Can attach a service to a network" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))

      network_in = network_hash(user.account_id)
      response = post("/api/v1/networks/save", {credentials: user.credentials, network: network_in})
      expect(response.status).to eq 200
      network_json = JSON.parse(response.body)

      # Create a couple services and add to network
      service_hashes = []
      (1..2).each do
        service = service_hash(user['account_id'])
        service_hashes << service
        response = post "/api/v1/services/save", {service: service, credentials: session[:credentials]}
        expect(response.status).to eq 200
        service_json = JSON.parse(response.body)

        response = put("/api/v1/services/add_to_network", {credentials: user.credentials, service_id: service_json['id'], network_id: network_json['id']})
        expect(response.status).to eq 200
        services = JSON.parse(response.body)
        expect(services['networks'].first['id']).to eq network_json['id']
      end
    end
    
    
  end
  
end