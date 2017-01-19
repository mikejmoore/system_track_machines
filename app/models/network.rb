
class Network < ActiveRecord::Base
  include NetworkLogic
  has_many :machines
  has_and_belongs_to_many :services, autosave: true, join_table: 'networks_services'
  has_and_belongs_to_many :environments, autosave: true, join_table: 'networks_environments'
  belongs_to :account
  
  def remove_environment(environment)
    remove_services_for_environment(environment)
    matches = environments.find { |env|
      env.id == environment.id
    }
    if (matches) && (matches.length > 0)
      self.environments -= matches
      self.save!
      self.reload
    end
  end
  
  def remove_services_for_environment(environment)
    matches = machine_services.find {|machine_service|
      machine_service.environment.id == environment.id
    }
    if (matches) 
      matches.each do |match|
        match.destroy!
      end
      self.reload
    end
  end
  
end
