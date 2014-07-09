class CreateStartups < ActiveRecord::Migration
  def change
    create_table :startups do |t|
      t.string :name
      t.string :company_size
      t.string :image
      t.text :description
      t.text :byline
      t.string :phone_number
      t.boolean :confirmed
      t.integer :total_funding
      t.integer :number_of_investments
      t.string :funding_stage
      t.timestamps
    end

    add_index :startups, :name
  end
end
