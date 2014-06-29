class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.string :subject
      t.integer :message_thread_id
      t.timestamps
    end
  end
end
