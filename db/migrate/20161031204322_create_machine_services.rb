class CreateMachineServices < ActiveRecord::Migration
  def change
    create_table :machine_services do |t|
      t.integer :machine_id, null: false
      t.integer :service_id, null: false
      t.integer  :environment_id, null: false
      t.string  :ip_address, null: true
      t.timestamps null: false
    end
    add_index :machine_services, :machine_id
    add_index :machine_services, :service_id
  end
end
