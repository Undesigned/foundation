class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.integer :addressable_id
      t.integer :addressable_type
      t.timestamps
    end
    add_index :addresses, [:addressable_id, :addressable_type]
  end
end
