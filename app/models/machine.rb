
class Machine < ActiveRecord::Base
  include MachineLogic
  belongs_to :network
  belongs_to :environment
  has_many :machine_tags
  has_many :network_cards
  has_many :machine_services
  
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
