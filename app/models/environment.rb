class Environment < ActiveRecord::Base
  has_and_belongs_to_many :networks, autosave: true, join_table: 'networks_environments'
  has_and_belongs_to_many :services, autosave: true, join_table: 'services_environments'
  
end
