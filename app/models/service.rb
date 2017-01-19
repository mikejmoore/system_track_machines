
class Service < ActiveRecord::Base
  include ServiceLogic
  
  has_and_belongs_to_many :networks, autosave: true
  has_many :machine_services
  has_and_belongs_to_many :environments, autosave: true, join_table: 'services_environments'
  
  def remove_environment(environment)
    networks = Network.all
    networks.each do |network|
      same_env = network.environments.where('id = ?', environment.id)
      debugger
      network.machines.each do |machine|
        machine.remove_environment(environment)
      end
    end
    
    matches = self.environments.where(id: environment.id)
    if (matches) && (matches.length > 0)
      self.environments.delete(matches.first)
      self.save!
      self.reload
    else
    end
  end
  
  
  def add_environment(environment)
    matches = self.environments.where(id: environment.id)
    if (matches) && (matches.length > 0)
    else
      self.environments << environment
      self.save!
      self.reload
    end
  end
  
  
end
