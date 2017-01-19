require_relative "./base_controller"

module Api
  module V1

    class NetworksController < V1::BaseController
      #before_filter :user_from_params

      def index
        account_id = @user.account_id.to_i
        account_id = params[:account_id].to_i if (params[:account_id]) 
        if (@user.account_id != account_id) && (!@user.is_super_user?)
          render text: "User (@user.email) does not have permission to networks on account: #{account_id}", status: 403
        else
          networks = Network.where(account_id: account_id)
          if (networks == nil)
            render text: [].to_json
          else
            render text: networks.to_json(:include=> [:environments])
          end
        end
      end
      
      def status_list
        list = []
        Network::STATUS.keys.each do |key|
          list << {code: key.to_s, name: Network::STATUS[key]}
        end
        render text: list.to_json
      end
      
      def save
        network_json = params[:network]
        account_id = @user.account_id.to_i
        
        network = nil
        if (network_json[:id])
          network = Network.find(network_json[:id].to_i)
        else
          network = Network.new
        end
        
        network.account_id = account_id
        network.name = network_json[:name]
        network.code = network_json[:code]
        network.status = network_json[:status]
        network.address = network_json[:address]
        network.mask = network_json[:mask]
        network.gateway = network_json[:gateway]
        network.broadcast = network_json[:broadcast]
        network.status = network_json[:status]
        if (network_json[:price])
          network.price = network_json[:price].to_f 
        else
          network.price = nil 
        end
        network.activation_date = Date.parse(network_json[:activation_date]) if (network_json[:activation_date])
        network.save
        render text: network.to_json(:include=> [:environments])
      end
   
      def get
        network_id = params[:network_id].to_i
        render text: Network.find(network_id).to_json(:include=> [:environments])
      end
  
    end
    
  end
end