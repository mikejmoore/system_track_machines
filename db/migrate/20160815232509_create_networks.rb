class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.integer :account_id, null: false
      t.string  :name,   null: false
      t.string  :code,   null: false
      t.string  :status,   null: false
      t.string  :address,   null: true
      t.string  :mask,   null: true
      t.string  :gateway, null: true
      t.string  :broadcast, null: true
      t.decimal :price, :precision => 8, :scale => 2
      t.datetime :activation_date
      t.timestamps null: false
    end

  end
end
