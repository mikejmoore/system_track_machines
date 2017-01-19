class MachineService < ActiveRecord::Base
  belongs_to :service
  belongs_to :machine
  belongs_to :environment
  validate :cannot_have_service_in_environment_not_in_network

  def cannot_have_service_in_environment_not_in_network
    if (machine.network)
      env_match = machine.network.environments.find {|e| 
        e.id == environment.id
      }
      if (!env_match)
        errors.add(:environment, "Cannot assign environment to service on machine that is not part of network")
      end
    end
  end
  
end
