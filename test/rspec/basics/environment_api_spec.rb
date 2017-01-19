require_relative '../spec_helper'


describe "Environments", :type => :api do
  include SystemTrack
  
  context "Find environments" do
    
    it "Can find my environments" do
      session = {}
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]

      environment_hashes = []
      (1..3).each do
        environment = environment_hash(user['account_id'])
        environment_hashes << environment
        response = post "/api/v1/environments/save", {environment: environment, credentials: session[:credentials]}
        expect(response.status).to eq 200
        environment_back = JSON.parse(response.body)
      end
      
      response = get "/api/v1/environments/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      environments_json = JSON.parse(response.body)
      expect(environments_json.length).to eq environment_hashes.length
      
      response = delete "/api/v1/environments/delete", {account_id: user.account_id, credentials: session[:credentials], environment_id: environments_json.first['id']}
      expect(response.status).to eq 200

      response = get "/api/v1/environments/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      environments_json = JSON.parse(response.body)
      expect(environments_json.length).to eq (environment_hashes.length - 1)
    end
  end
  
  context "Networks can be assigned environment(s)" do

    it "Machines in assigned network can host services of particular environments" do
      session = {}
      user = register_random_user(session)
      credentials = session[:credentials]
      account_id = user.account_id
      
      environment = create_environment(session, account_id)
      environment_2 = create_environment(session, account_id)
      
      
      network = network_hash(user['account_id'])
      response = post "/api/v1/networks/save", {network: network, credentials: session[:credentials]}
      expect(response.status).to eq 200
      network = JSON.parse(response.body)
      
      response = put "/api/v1/environments/add_to_network", {
              network_id: network['id'], 
              environment_id: environment['id'], 
              account_id: user.account_id, 
              credentials: session[:credentials]
            }
      expect(response.status).to eq 200
      

      response = get "/api/v1/networks/get", {network_id: network['id'], credentials: session[:credentials]}
      network = JSON.parse(response.body)
      expect(network['environments'].length).to eq 1
      
      # Create machine in network
      machine = machine_hash(user['account_id'])
      machine[:network_id] = network['id']
      machine = save_machine(session, machine)

      service = service_hash(user['account_id'])
      service = save_service(session, service)
      service = add_environment_to_service(session, service, environment)
      
      response = put "/api/v1/services/add_to_machine", {
              machine_id: machine['id'], 
              service_id: service['id'], 
              environment_id: environment['id'], 
              account_id: user.account_id, 
              credentials: session[:credentials]
            }
      expect(response.status).to eq 200
      machine = JSON.parse(response.body)
      expect(machine['machine_services'].first['service_id']).to eq service['id']
      
      puts "Cannot add service to machine with environment 2, since environment 2 not assigned to network"
      response = put "/api/v1/services/add_to_machine", {
              machine_id: machine['id'], 
              service_id: service['id'], 
              environment_id: environment_2['id'], 
              account_id: user.account_id, 
              credentials: session[:credentials]
            }
      expect(response.status).to eq 500
      
    end
    
    it "Machines not in networks assigned an environment cannot host services of other environments" do
    end
    
  end
end