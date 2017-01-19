require_relative "./base_controller"

module Api
  module V1

    class MachinesController < V1::BaseController
      skip_before_action :authenticate_token, only: [:ansible_hosts]
      skip_before_action :find_user, only: [:ansible_hosts]
      skip_before_action :destroy_session, only: [:ansible_hosts]
      
      
      #before_filter :user_from_params
      def index
        account_id = @user.account_id.to_i
        account_id = params[:account_id].to_i if (params[:account_id]) 
        if (@user.account_id != account_id) && (!@user.is_super_user?)
          render text: "User (@user.email) does not have permission to machines on account: #{account_id}", status: 403
        else
          machines = Machine.where(account_id: account_id)
          if (machines == nil)
            render text: [].to_json
          else
            render text: machines.to_json(:include=> [:network, :network_cards, :machine_tags, machine_services: {include: :environment}])
          end
        end
      end
      
      def show
        raise "Not Implemented"
      end
      
      def save
        machine_json = params[:machine]
        account_id = @user.account_id
        machine = nil
        if (machine_json[:id])
          machine = Machine.find(machine_json['id'].to_i)
        else
          machine = Machine.new
        end
        machine.account_id = account_id
        machine.name = machine_json[:name]
        machine.code = machine_json[:code]
        machine.network_id = machine_json[:network_id]
        machine.status = machine_json[:status]
        machine.ip_address = machine_json[:ip_address]
        machine.dns_name = machine_json[:dns_name]
        machine.brand = machine_json[:brand]
        machine.model = machine_json[:model]
        machine.os = machine_json[:os]
        machine.status = machine_json[:status]
        machine.price = machine_json[:price].to_f if (machine_json[:price])
        machine.purchase_date = Date.parse(machine_json[:purchase_date]) if (machine_json[:purchase_date])
        machine.activation_date = Date.parse(machine_json[:activation_date]) if (machine_json[:activation_date])
        machine.save!
        
        # if (machine_json['network_cards'])
        #   before_nics = []
        #   machine.network_cards.each do |nic|
        #     before_nics << nic
        #   end
        #   machine_json['network_cards'].each do |nic_json|
        #     same_ip_nics = before_nics.select { |n|
        #       n.ip_address == nic_json['ip_address']
        #     }
        #     nic = nil
        #     if (!same_ip_nics) || (same_ip_nics.length == 0)
        #       nic = NetworkCard.new
        #       nic.ip_address = nic_json['ip_address']
        #       machine.network_cards << nic
        #     elsif (same_ip_nics.length == 1)
        #       nic = same_ip_nics.first
        #       same_ip_nics.first.save!
        #       nic.save!
        #     else
        #       raise "More than one nic has ip adress: #{nic_json['ip_address']} for Machine: #{machine.code}"
        #     end
        #
        #     if (nic)
        #       nic.mac_address = nic_json['mac_address']
        #       nic.brand = nic_json['brand']
        #       nic.model = nic_json['model']
        #       nic.interface = nic_json['interface']
        #       nic.ssh_service = (nic_json['ssh_service'] == 'true')
        #       nic.machine = machine
        #       nic.save!
        #     end
        #   end
        #
        #   # Delete any NIC's not passed
        #   machine.reload
        #   machine.network_cards.each do |nic|
        #     found = false
        #     machine_json['network_cards'].each do |nic_json|
        #       if (nic_json['ip_address'] == nic.ip_address)
        #         found = true
        #       end
        #     end
        #     nic.destroy if (!found)
        #   end
        # end
        
        current_tags = []
        if (machine_json['machine_tags'])
          machine_json['machine_tags'].each do |machine_tag_to_save|
            machine_tag = MachineTag.new
            machine_tag.machine_id = machine.id
            machine_tag.tag = machine_tag_to_save['tag']
            begin
              machine_tag.save!
            rescue ActiveRecord::RecordNotUnique => e
              # Swallow exception and ignore request to save duplicate tag
            end
            current_tags << machine_tag_to_save['tag']
          end
          machine.machine_tags.each do |machine_tag|
            if (current_tags.include? machine_tag.tag)
            else
              machine_tag.destroy
            end
          end
        end
        machine.reload
        render text: machine.to_json(:include=> [:network, :network_cards, :machine_tags, machine_services: {include: :environment}])
      end
      
      def save_network_card
        machine_id = params[:machine_id].to_i
        machine = Machine.find(machine_id)
        raise "Invalid 'machine_id' passed" if (!machine)
        
        nic_json = params[:network_card]
        nic_id= nic_json['id'].to_i if (nic_json['id'])

        if (nic_id)
          nic = NetworkCard.find(nic_id)
        else
          nic = NetworkCard.new
        end

        nic.mac_address = nic_json['mac_address']
        nic.brand = nic_json['brand']
        nic.model = nic_json['model']
        nic.ip_address = nic_json['ip_address']
        nic.interface = nic_json['interface']
        nic.ssh_service = (nic_json['ssh_service'] == 'true')
        nic.machine = machine
        nic.save!
        machine.reload
        render text: machine.to_json(:include=> [:network, :network_cards, :machine_tags, machine_services: {include: :environment}])
      end
      
      def delete_network_card
        nic_id = params[:network_card_id].to_i
        nic = NetworkCard.find(nic_id)
        machine = nic.machine
        nic.destroy
        machine.reload
        render text: machine.to_json(:include=> [:network, :network_cards, :machine_tags, machine_services: {include: :environment}])
      end
      
      def toggle_service
        machine_id = params[:machine_id].to_i
        service_id = params[:service_id].to_i
        environment_id = params[:environment_id]
        machine = Machine.find(machine_id)
        machine_service = machine.machine_services.find_by_service_id(service_id)
        service_on = false
        if (machine_service)
          machine_service.destroy
        else
          machine_service = MachineService.new
          machine_service.service_id = service_id
          machine_service.machine_id = machine_id
          machine_service.environment_id = environment_id
          machine_service.save
          service_on = true
        end
        render text: {service_on: service_on}.to_json
      end
      
      def get
        machine_id = params[:machine_id].to_i
        machine = Machine.find(machine_id)
        render text: machine.to_json(:include=> [:network, :network_cards, :machine_tags, machine_services: {include: :environment}])
      end

      def status_list
        list = []
        Machine::STATUS.keys.each do |key|
          list << {code: key.to_s, name: Machine::STATUS[key]}
        end
        render text: list.to_json
      end
   
      def ansible_hosts
        public_key_hash = params[:public_key_hash]
        key_data = SystemTrack::UsersProxy.new.find_ssh_key(public_key_hash)
        account_id = key_data['account']['id'].to_i
        
    
        return_data = {}
        operation = params[:operation]
        rsa_pub = key_data["public_key"]
        public_key = OpenSSHKeyConverter.decode_pubkey rsa_pub.split[1]
  
        
        return_data = {}
        #List machines by code
        machines = Machine.where(account_id: account_id)
        machines.each do |machine|
          if (machine.code)
            code = machine.code.split(".").join("_").split(" ").join("_")
            return_data[code] = {hosts: [machine.ip_address], vars: {}}
            
          end
        end
        
        #Machines by network code
        networks = Network.where(account_id: account_id)
        if (networks != nil)
          networks.each do |network|
            machine_ips = []
            code = network.code
            if (code)
              code = network.name.split(".").join("_").split(" ").join("_")
              network.machines.each do |machine|
                machine_ips << machine.ip_address if (machine.ip_address)
              end
              return_data[code] = {hosts: machine_ips, vars: {}}
            end
          end
        end
  
        cipher_info = CryptUtils.encrypt(return_data.to_json)

        # Encrypt symetric key with user's rsa public key.  User will need to decrypt symetric key on client side to perform symetric decipher.
        key = public_key.public_encrypt(cipher_info[:key])
        key = [key].pack('m')
        cipher_info[:key] = key
        render text: cipher_info.to_json
      end
    end
    
  end
end