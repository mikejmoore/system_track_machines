
class AccountApiFactory
  
  def self.random
    {
      code: RandomWord.nouns.next,
      name: RandomWord.nouns.next + " " + RandomWord.nouns.next
    }
  end
  
  def self.create(credentials, object = self.random)
    conn = Faraday.new(:url => 'http://localhost:3000') do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    
    account_in = {account: {name: object[:name], code: object[:code]}}
    
    response = post "/api/v1/accounts/save", account_in.merge(credentials)
    expect(response.status).to eq 200
    
    resp = conn.post '/articles/publish', payload    
    
  end
  
end