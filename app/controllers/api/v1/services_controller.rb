require_relative "./base_controller"

module Api
  module V1

    class ServicesController < V1::BaseController
      #before_filter :user_from_params

      def index
        account_id = @user.account_id.to_i
        account_id = params[:account_id].to_i if (params[:account_id]) 
        if (@user.account_id != account_id) && (!@user.is_super_user?)
          render text: "User (@user.email) does not have permission to networks on account: #{account_id}", status: 403
        else
          services = Service.where(account_id: account_id)
          if (services == nil)
            render text: [].to_json
          else
            render text: services.to_json(:include=> [:environments, machine_services: {include: :environment}])
          end
        end
      end
      
      
      def save
        service_json = params[:service]
        account_id = @user.account_id.to_i
        service = nil
        if (service_json[:id])
          service = Service.find(service_json[:id].to_i)
        else
          service = Service.new
        end
        
        service.account_id = account_id
        service.name = service_json[:name]
        service.code = service_json[:code]
        service.description = service_json[:description]
        service.save!
        
        # machine_ids_to_delete = []
        # service.machine_services.each do |machine_service|
        #   machine_ids_to_delete << machine_service.machine_id
        # end
        # if (service_json['machine_services'])
        #   service_json['machine_services'].each do |machine_service_json|
        #     machine_id = machine_service_json['machine_id']
        #     ip_address = machine_service_json['ip_address']
        #     machine_ids_to_delete.delete(machine_id)
        #
        #     machine = Machine.find(machine_id)
        #     machine_service = nil
        #
        #     matching = MachineService.where("machine_id=#{machine_id} and service_id=#{service.id}")
        #     raise "Unexpected: more than one machine_service record for machine: #{machine_id} and service: #{service.id}" if (matching) && (matching.length > 1)
        #     machine_service = matching.first if (matching) && (matching.length > 0)
        #
        #     machine_service = MachineService.new if (!machine_service)
        #     machine_service.service = service
        #     machine_service.machine = machine
        #     machine_service.environment_id = machine_service_json['environment_id']
        #     machine_service.ip_address = ip_address
        #     machine_service.save!
        #   end
        # end
        
        
        service.reload
        service.machine_services.each do |machine_service|
          if (machine_ids_to_delete.include? machine_service.machine_id )
            machine_service.destroy
          end
        end
        service.reload
        render text: service.to_json(:include=> [:environments, :networks, machine_services: {include: :environment}])
      end
   
      def get
        service_id = params[:service_id].to_i
        render text: Service.find(service_id).to_json(:include => [:environments, :networks, machine_services: {include: :environment}])
      end
  
      def status_list
        list = []
        Service::STATUS.keys.each do |key|
          list << {code: key.to_s, name: Service::STATUS[key]}
        end
        render text: list.to_json
      end
  
      def add_to_network
        network_id = params[:network_id]
        service_id = params[:service_id]
        service = Service.find(service_id.to_i)
        network = Network.find(network_id.to_i)
        service.networks << network if (!service.networks.include? network)
        service.save!
        render text: service.to_json(:include=> [:environments, :networks, machine_services: {include: :environment}])
      end

      def remove_from_network
        network_id = params[:network_id]
        service_id = params[:service_id]
        service = Service.find(service_id.to_i)
        network = Network.find(network_id.to_i)
        service.networks.delete(network) if (service.networks.include? network)
        service.save!
        render text: service.to_json(:include=> [:environments, :networks, machine_services: {include: :environment}])
      end

      def add_to_machine
        machine_id = params[:machine_id]
        service_id = params[:service_id]
        ip_address = params[:ip_address]
        environment_id = params[:environment_id]

        service = Service.find(service_id.to_i)
        machine = Machine.find(machine_id.to_i)
        environment = Environment.find(environment_id.to_i)

        machine_service = MachineService.new
        machine_service.service = service
        machine_service.machine = machine
        machine_service.ip_address = ip_address
        machine_service.environment = environment
        machine_service.save!
        
        service.machine_services << machine_service
        service.save!
        render text: service.to_json(:include=> [:environments, :networks, machine_services: {include: :environment}])
      end
      
      def remove_from_machine
        account_id = @user.account_id.to_i
        machine_service_id = params[:machine_service_id]
        machine_service = MachineService.find(machine_service_id)

        service = machine_service.service
        raise SystemTrack::NotAuthorizedException.new("User not in same account as machine") if (service.account_id != account_id)
        machine_service.destroy!
        service.reload
        render text: service.to_json(:include=> [:environments, :networks, machine_services: {include: :environment}])
      end
  
    end
    
  end
end