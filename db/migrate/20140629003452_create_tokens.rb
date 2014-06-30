class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :content
      t.string :provider
      t.belongs_to :user
      t.timestamps
    end

    add_index :tokens, [:user_id, :provider], unique: true
  end
end
