require_relative '../spec_helper'

include SystemTrack

describe "Tagging", :type => :api do

  context "Finding tags" do
    
    it "Find no tags for current user if no public or private tags for account saved" do
      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      
      response = get "/api/v1/tags/index", {credentials: credentials, object_type: 'machine'}
      expect(response.status).to eq 200
      tags = JSON.parse(response.body)
      expect(tags.length).to eq 0
    end

    
    it "User can create a private tag (to account)" do
      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      
      tag_1 = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: credentials, tag: tag_1}
      expect(response.status).to eq 200
      tag_1_saved = JSON.parse(response.body)
      expect(tag_1_saved['account_id']).to eq user['account_id']
      
      response = get "/api/v1/tags/index", {credentials: credentials, object_type: 'machine'}
      expect(response.status).to eq 200
      tags = JSON.parse(response.body)
      expect(tags.length).to eq 1
    end

    it "Super user can create a public for all accounts" do
      session = {}
      super_user = UserObject.new(UsersProxy.new.sign_in(session, TestConstants::SUPER_USER[:email], TestConstants::SUPER_USER[:password]))
      
      tag_1 = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: super_user.credentials, tag: tag_1}
      expect(response.status).to eq 200
      tag_1_saved = JSON.parse(response.body)
      expect(tag_1_saved['account_id']).to eq nil
    end
    
    it "Normal user can see private and public tags for object type" do
      session = {}
      super_user = UserObject.new(UsersProxy.new.sign_in(session, TestConstants::SUPER_USER[:email], TestConstants::SUPER_USER[:password]))
      public_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: super_user.credentials, tag: public_tag}
      expect(response.status).to eq 200

      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      private_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: credentials, tag: private_tag}
      expect(response.status).to eq 200
      
      response = get "/api/v1/tags/index", {credentials: credentials, object_type: 'machine'}
      expect(response.status).to eq 200
      tags = JSON.parse(response.body)
      expect(tags.select {|t| t['code'] == private_tag[:code]}.length).to eq 1
      expect(tags.select {|t| t['code'] == public_tag[:code]}.length).to eq 1
    end
    
    it "Normal user shouldn't see other account's tags" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(UsersProxy.new.register(session, {user: other_user}))
      credentials = session[:credentials]
      other_private_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: credentials, tag: other_private_tag}
      expect(response.status).to eq 200
      
      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      private_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: credentials, tag: private_tag}
      expect(response.status).to eq 200
      
      response = get "/api/v1/tags/index", {credentials: credentials, object_type: 'machine'}
      expect(response.status).to eq 200
      tags = JSON.parse(response.body)
      expect(tags.select {|t| t['code'] == private_tag[:code]}.length).to eq 1
      expect(tags.select {|t| t['code'] == other_private_tag[:code]}.length).to eq 0
    end

    it "User cannot create tag that duplicates code of public tag" do
      session = {}
      super_user = UserObject.new(UsersProxy.new.sign_in(session, TestConstants::SUPER_USER[:email], TestConstants::SUPER_USER[:password]))
      public_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: super_user.credentials, tag: public_tag}
      expect(response.status).to eq 200

      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      private_tag = tag_hash('machine')
      private_tag[:code] = public_tag[:code]
      response = post "/api/v1/tags/save", {credentials: credentials, tag: private_tag}
      expect(response.status).to eq 500
    end    

    it "User cannot create tag that duplicates code of private tag in same account" do
      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      private_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: credentials, tag: private_tag}
      expect(response.status).to eq 200

      response = post "/api/v1/tags/save", {credentials: credentials, tag: private_tag}
      expect(response.status).to eq 500
    end    

    it "User can create tag that duplicates code of tag in different account" do
      session = {}
      other_user = unregistered_user
      other_user = UserObject.new(UsersProxy.new.register(session, {user: other_user}))
      credentials = session[:credentials]
      other_private_tag = tag_hash('machine')
      response = post "/api/v1/tags/save", {credentials: credentials, tag: other_private_tag}
      expect(response.status).to eq 200
      
      session = {}
      user = unregistered_user
      user = UserObject.new(UsersProxy.new.register(session, {user: user}))
      credentials = session[:credentials]
      private_tag = tag_hash('machine')
      private_tag[:code] = other_private_tag[:code]
      response = post "/api/v1/tags/save", {credentials: credentials, tag: private_tag}
      expect(response.status).to eq 200
    end    
    
    
  end
  
end