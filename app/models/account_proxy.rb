class AccountProxy
  @@address = nil
  
  def self.address=(url)
    @@connection = Faraday.new(:url => url) do |faraday|
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
  
  def self.connection
    return @@connection
  end
  
  def self.user(params)
    @@connection.get "/api/v1/"
  end
  
  
end