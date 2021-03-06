class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :bio
      t.string :image
      t.string :location
      t.text :what_ive_built
      t.text :what_i_do
      t.text :criteria
      t.string :provider
      t.string :uid
      t.boolean :investor
      t.integer :birthyear
      t.integer :technical_points
      t.integer :design_points
      t.integer :business_points

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [:provider, :uid], unique: true
  end
end
