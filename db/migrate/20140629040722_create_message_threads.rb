class CreateMessageThreads < ActiveRecord::Migration
  def change
    create_table :message_threads do |t|
      t.string :uid
      t.timestamps
    end

    create_table :message_threads_users, :id => false do |t|
        t.references :message_thread
        t.references :user
    end
    add_index :message_threads_users, [:message_thread_id, :user_id]
    add_index :message_threads_users, :user_id
  end
end
