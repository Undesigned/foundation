class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.string :name

      t.timestamps
    end
    add_index :markets, :name, unique: true

    create_table :markets_users, :id => false do |t|
        t.references :market
        t.references :user
    end
    add_index :markets_users, [:market_id, :user_id], unique: true
    add_index :markets_users, :user_id
  end
end
