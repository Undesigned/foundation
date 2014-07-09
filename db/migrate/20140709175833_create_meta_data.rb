class CreateMetaData < ActiveRecord::Migration
  def change
    create_table :meta_data do |t|
      t.string :name
      t.string :value
      t.string :source
      t.string :owner_type
      t.integer :owner_id
      t.timestamps
    end

    add_index :meta_data, [:owner_id, :owner_type, :name, :source], unique: true
  end
end
