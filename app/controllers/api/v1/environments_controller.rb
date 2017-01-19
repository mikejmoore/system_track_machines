require_relative "./base_controller"

module Api
  module V1

    class EnvironmentsController < V1::BaseController
      
      def index
        account_id = @user.account_id.to_i
        account_id = params[:account_id].to_i if (params[:account_id]) 
        if (@user.account_id != account_id) && (!@user.is_super_user?)
          render text: "User (@user.email) does not have permission to environments on account: #{account_id}", status: 403
        else
          environments = Environment.where(account_id: account_id)
          render text: environments.to_json
        end
      end
      
      def save
        environment_json = params[:environment]
        account_id = @user.account_id
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != account_id)
        environment = nil
        if (environment_json[:id])
          environment = Environment.find(environment_json['id'].to_i)
        else
          environment = Environment.find_by_code(environment_json['code'])
        end
        environment = Environment.new if (!environment)
        
        environment.account_id = account_id
        environment.name = environment_json[:name]
        environment.code = environment_json[:code]
        environment.category = environment_json[:category]
        environment.save!
        render text: environment.to_json
      end
      
      def delete
        environment_id = params[:environment_id].to_i
        environment = Environment.find(environment_id)
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != environment['account_id'])
        environment.destroy
        render text: {message: "ok"}.to_json
      end
      
      def get
        environment_id = params[:environment_id].to_i
        environment = Environment.find(environment_id)
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != environment['account_id'])
        render text: environment.to_json
      end
      
      
      def toggle_network_environment
#        ", {credentials: credentials, machine_id: machine_id, service_id: service_id, environment_id: environment_id}
        environment_id = params[:environment_id].to_i
        network_id = params[:network_id].to_i
        environment = Environment.find(environment_id)
        network = Network.find(network_id)
        raise SystemTrack::NotAuthorizedException.new('User not in same account of network') if (@user.account_id != network['account_id'])
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != environment['account_id'])

        matches = network.environments.where(id: environment_id)
        if (matches) && (matches.length > 0)
          network.environments.delete(matches.first)
        else
          network.environments << environment
        end
        network.save!
        render text: network.to_json(include: :environments)
        
      end
      
      def add_to_network
        environment_id = params[:environment_id].to_i
        network_id = params[:network_id].to_i
        environment = Environment.find(environment_id)
        network = Network.find(network_id)
        raise SystemTrack::NotAuthorizedException.new('User not in same account of network') if (@user.account_id != network['account_id'])
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != environment['account_id'])
        matches = network.environments.where(id: environment_id)
        if (matches) && (matches.length > 0)
        else
          network.environments << environment
        end
        network.save!
        render text: network.to_json(include: :environments)
      end
      
      def add_to_service
        environment_id = params[:environment_id].to_i
        service_id = params[:service_id].to_i
        environment = Environment.find(environment_id)
        service = Service.find(service_id)
        raise SystemTrack::NotAuthorizedException.new('User not in same account of service') if (@user.account_id != service['account_id'])
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != environment['account_id'])
        service.add_environment(environment)
        render text: service.to_json(include: :environments)
      end
      
      def remove_from_service
        environment_id = params[:environment_id].to_i
        service_id = params[:service_id].to_i
        environment = Environment.find(environment_id)
        service = Service.find(service_id)
        raise SystemTrack::NotAuthorizedException.new('User not in same account of service') if (@user.account_id != service['account_id'])
        raise SystemTrack::NotAuthorizedException.new('User not in same account of environment') if (@user.account_id != environment['account_id'])
        service.remove_environment(environment)
        render text: service.to_json(include: :environments)
      end
        
    end
  end
end