class CreateNetworkCards < ActiveRecord::Migration
  def change
    create_table :network_cards do |t|
      t.integer :machine_id
      t.integer :network_id
      t.string  :ip_address,   null: true
      t.string  :mac_address,   null: true
      t.string  :interface,   null: true
      t.string  :brand,   null: true
      t.string  :model,   null: true
      t.boolean  :ssh_service,  default: false, null: false
      t.timestamps null: false
    end
  end
end
