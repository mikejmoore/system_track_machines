class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.integer :account_id
      t.integer :network_id
      t.string  :name,   null: false
      t.string  :code,   null: false
      t.string  :status,   null: false
      t.integer  :environment_id,   null: true
      t.string  :ip_address
      t.string  :os
      t.string  :dns_name
      t.string  :code
      t.string  :brand
      t.string  :model
      t.integer :drive_space
      t.integer :drive_speed
      t.integer :cpu_speed
      t.integer :cpu_count
      t.integer :memory
      t.decimal :price, :precision => 8, :scale => 2
      t.datetime :purchase_date
      t.datetime :activation_date
      t.timestamps null: false
    end
    
    create_table :tags do |t|
      t.integer :account_id
      t.string  :object_type, null: false
      t.string  :code,            null: false
      t.string  :name
      t.timestamps null: false
    end
    
    create_table :machine_tags do |t|
      t.integer :machine_id,  null: false
      t.string :tag,      null: false
    end
    add_index :machine_tags, [:machine_id, :tag], :unique => true
    
    create_table :machine_network_interfaces do |t|
      t.integer :machine_id
      t.integer :network_id
      t.string  :mac_address
      t.string  :code
      t.integer :dhcp
    end
    
  end
end
