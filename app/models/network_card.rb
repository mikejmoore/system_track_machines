class NetworkCard < ActiveRecord::Base
  belongs_to :machine
  belongs_to :network
end
