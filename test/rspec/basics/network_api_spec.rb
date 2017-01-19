require_relative '../spec_helper'

describe "Networks Services", :type => :api do
  context "Find network information" do
    
    it "Can find my networks" do
      session = {}
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
      
      credentials = session[:credentials]
      network_hashes = []
      (1..3).each do
        network = network_hash(user['account_id'])
        network_hashes << network
        response = post "/api/v1/networks/save", {network: network, credentials: session[:credentials]}
        expect(response.status).to eq 200
        network_back = JSON.parse(response.body)
      end
      
      response = get "/api/v1/networks/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      networks_json = JSON.parse(response.body)
      expect(networks_json.length).to eq network_hashes.length
      
      SystemTrack::UsersProxy.new.logoff(session)
      response = get "/api/v1/networks/index", {credentials: credentials}
      expect(response.status).to eq 401
    end
    
    it "Can retrieve a list of valid network statuses" do
      response = get("/api/v1/networks/status_list", {})
      expect(response.status).to eq 200
      return_json = JSON.parse(response.body)
      expect(return_json.length).to eq Network::STATUS.keys.length
    end
    
    it "Cannot see other accounts networks" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: other_user}))
      (1..2).each do
        network = network_hash(other_user.account_id)
        post "/api/v1/networks/save", {network: network, credentials: session[:credentials]}
      end
      
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
      expect(other_user['account_id']).to_not eq user.account_id

      response = get "/api/v1/networks/index", {account_id: other_user.account_id, credentials: user.credentials}
      expect(response.status).to eq 403
    end
    
    it "Super user can see any account's networks'" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: other_user}))
      (1..2).each do
        network = network_hash(other_user.account_id)
        post "/api/v1/networks/save", {network: network, credentials: other_user.credentials}
      end
      
      super_user = UserObject.new(SystemTrack::UsersProxy.new.sign_in(session, TestConstants::SUPER_USER[:email], TestConstants::SUPER_USER[:password]))
      response = get "/api/v1/networks/index", {account_id: other_user.account_id, credentials: super_user.credentials}
      expect(response.status).to eq 200
      networks_json = JSON.parse(response.body)
      expect(networks_json.length).to eq 2
    end
    
  end
  
  context "Can change information about networks" do
    
    it "Can create a new network" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))

      network_in = network_hash(user.account_id)
      response = post("/api/v1/networks/save", {credentials: user.credentials, network: network_in})
      expect(response.status).to eq 200
      return_json = JSON.parse(response.body)
      
      expect(return_json['name']).to eq network_in[:name]
      expect(return_json['code']).to eq network_in[:code]
      expect(return_json['ip_address']).to eq network_in[:ip_address]
      expect(return_json['activation_date']).to_not be nil
      
    end
  end
  
end