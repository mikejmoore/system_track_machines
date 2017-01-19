class CreateServices < ActiveRecord::Migration
  def change
    
    create_table :environments do |t|
      t.integer :account_id, null: false
      t.string  :name,   null: false
      t.string  :code,   null: false
      t.string  :category,   null: false
      t.timestamps null: false
    end
    add_index :environments, [:account_id, :code], :unique => true
    add_index :environments, [:account_id, :name], :unique => true
    
    create_table :services do |t|
      t.integer :account_id, null: false
      t.string  :name,   null: false
      t.string  :code,   null: false
      t.string  :description
      t.text    :information
      t.timestamps null: false
    end
    add_index :services, [:account_id, :code], :unique => true


    create_table :networks_services, id: false do |t|
      t.column :network_id, :integer, null: false
      t.column :service_id, :integer, null: false
      t.column :environment_id, :integer
    end
    add_index :networks_services, [:service_id, :network_id], :unique => true

    create_table :services_environments, id: false do |t|
      t.column :service_id, :integer,   null: false
      t.column :environment_id, :integer,   null: false
    end
    add_index :services_environments, [:service_id, :environment_id], :unique => true
    
    create_table :networks_environments, id: false do |t|
      t.column :network_id, :integer,   null: false
      t.column :environment_id, :integer,   null: false
    end
    add_index :networks_environments, [:network_id, :environment_id], :unique => true
    
  end
end
