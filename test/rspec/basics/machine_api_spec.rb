require_relative '../spec_helper'


describe "Background Processes", :type => :api do
  include SystemTrack
  # let!(:user)  { {} }
  # let!(:machine)  { FactoryGirl.create :machine, account: user.account }
  #
  # let!(:other_account) { FactoryGirl.create :account }
  # let!(:other_machine)  { FactoryGirl.create :machine, account: other_account }
  

  context "Find machine information" do
    
    it "Can find my machines" do
      session = {}
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))


      expect(user.has_role?("staff")).to eq true
      expect(user.has_role?("account.admin")).to eq true
      
      expect(session[:credentials]).to_not be nil
      expect(session[:credentials][:uid]).to_not be nil
      expect(session[:user]).to_not be nil
      
      credentials = session[:credentials]
      machine_hashes = []
      (1..3).each do
        machine = machine_hash(user['account_id'])
        machine_hashes << machine
        response = post "/api/v1/machines/save", {machine: machine, credentials: session[:credentials]}
        expect(response.status).to eq 200
        machine_back = JSON.parse(response.body)
        expect(machine_back['machine_tags']).to_not be nil
        expect(machine_back['machine_tags'].length).to eq machine[:machine_tags].length
      end
      
      response = get "/api/v1/machines/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machines_json = JSON.parse(response.body)
      expect(machines_json.length).to eq machine_hashes.length
      SystemTrack::UsersProxy.new.logoff(session)
      response = get "/api/v1/machines/index", {credentials: credentials}
      expect(response.status).to eq 401
    end
    
    
    it "Can find save and find network cards on a machine" do
      session = {}
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))


      expect(user.has_role?("staff")).to eq true
      expect(user.has_role?("account.admin")).to eq true
      
      expect(session[:credentials]).to_not be nil
      expect(session[:credentials][:uid]).to_not be nil
      expect(session[:user]).to_not be nil
      
      credentials = session[:credentials]
      machine_hash = machine_hash(user['account_id'])
      
      # Make sure factory generates 4 nics
      expect(machine_hash[:network_cards].length).to eq 4
      
      response = post "/api/v1/machines/save", {machine: machine_hash, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machine = JSON.parse(response.body)
      
      
      machine_hash[:network_cards].each do |nic|
        response = post "/api/v1/machines/save_network_card", {machine_id: machine['id'], network_card: nic, credentials: session[:credentials]}
        expect(response.status).to eq 200
      end
      

      response = get "/api/v1/machines/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machines_json = JSON.parse(response.body)
      machine_json = machines_json.first
      expect(machine_json['network_cards'].length).to eq 4
    end
    
    it "Cannot see other accounts machines" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: other_user}))
      (1..2).each do
        machine = machine_hash(other_user.account_id)
        post "/api/v1/machines/save", {machine: machine, credentials: session[:credentials]}
      end
      
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))
      expect(other_user['account_id']).to_not eq user.account_id

      response = get "/api/v1/machines/index", {account_id: other_user.account_id, credentials: user.credentials}
      expect(response.status).to eq 403
    end
    
    it "Super user can see any account's machines'" do
      include SystemTrack
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: other_user}))
      (1..2).each do
        machine = machine_hash(other_user.account_id)
        post "/api/v1/machines/save", {machine: machine, credentials: other_user.credentials}
      end
      
      super_user = UserObject.new(SystemTrack::UsersProxy.new.sign_in(session, SystemTrack::TestConstants::SUPER_USER[:email], SystemTrack::TestConstants::SUPER_USER[:password]))
      response = get "/api/v1/machines/index", {account_id: other_user.account_id, credentials: super_user.credentials}
      expect(response.status).to eq 200
      machines_json = JSON.parse(response.body)
      expect(machines_json.length).to eq 2
    end
    
  end
  
  context "Can change information about machines" do
    
    it "Can create a new machine" do
      session = {}
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: unregistered_user}))
      
      network = Network.new
      network.name = RandomWord.nouns.next
      network.address = "192.168.40.0"
      network.code = "my_net"
      network.mask = "255.255.0.0"
      network.account_id = user.account_id
      network.status = Network::STATUS[:activated]
      network.save!
      
      machine_in = machine_hash(user.account_id)
      machine_in[:network_id] = network.id
      response = post("/api/v1/machines/save", {credentials: user.credentials, machine: machine_in})
      expect(response.status).to eq 200
      return_json = JSON.parse(response.body)
      
      expect(return_json['name']).to eq machine_in[:name]
      expect(return_json['code']).to eq machine_in[:code]
      expect(return_json['ip_address']).to eq machine_in[:ip_address]
      expect(return_json['network_id']).to eq machine_in[:network_id].to_i
      expect(return_json['price']).to_not be nil
      expect(return_json['purchase_date']).to_not be nil
      
    end
    
    
    it "Can edit and delete network cards" do
      session = {}
      user = unregistered_user
      user = UserObject.new(SystemTrack::UsersProxy.new.register(session, {user: user}))

      expect(user.has_role?("staff")).to eq true
      expect(user.has_role?("account.admin")).to eq true
      
      expect(session[:credentials]).to_not be nil
      expect(session[:credentials][:uid]).to_not be nil
      expect(session[:user]).to_not be nil
      
      credentials = session[:credentials]
      machine_hash = machine_hash(user['account_id'])
      
      # Make sure factory generates 4 nics
      expect(machine_hash[:network_cards].length).to eq 4
      
      response = post "/api/v1/machines/save", {machine: machine_hash, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machine = JSON.parse(response.body)
      
      machine_hash[:network_cards].each do |nic|
        response = post "/api/v1/machines/save_network_card", {machine_id: machine['id'], network_card: nic, credentials: session[:credentials]}
        expect(response.status).to eq 200
      end
      
      response = get "/api/v1/machines/index", {account_id: user.account_id, credentials: session[:credentials]}
      expect(response.status).to eq 200
      machines_json = JSON.parse(response.body)
      machine_json = machines_json.first
      expect(machine_json['network_cards'].length).to eq 4
      
      # Delete a card
      deleted_card = machine_json['network_cards'].first
      response = delete "/api/v1/machines/delete_network_card", {machine_id: machine['id'], network_card_id: deleted_card['id'], credentials: session[:credentials]}
      expect(response.status).to eq 200
      machine_json = JSON.parse(response.body)
      expect(machine_json['network_cards'].length).to eq 3  #Card was deleted.
      matches_to_deleted_card = machine_json['network_cards'].find {|m| m['ip_address'] == deleted_card['ip_address']}
      expect(matches_to_deleted_card).to eq nil
    end
    
      
  end
end