class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.string :name

      t.timestamps
    end
    add_index :markets, :name, unique: true

    create_table :markets_startups, :id => false do |t|
        t.references :market
        t.references :startup
    end
    add_index :markets_startups, [:market_id, :startup_id], unique: true
    add_index :markets_startups, :startup_id
  end
end
