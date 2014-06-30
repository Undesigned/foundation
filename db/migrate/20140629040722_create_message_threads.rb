class CreateMessageThreads < ActiveRecord::Migration
  def change
    create_table :message_threads do |t|
      t.string :uid
      t.timestamps
    end
    add_index :message_threads, :uid, unique: true

    create_table :message_threads_users, :id => false do |t|
        t.references :message_thread
        t.references :user
    end
    add_index :message_threads_users, [:message_thread_id, :user_id], unique: true
    add_index :message_threads_users, :user_id
  end
end
