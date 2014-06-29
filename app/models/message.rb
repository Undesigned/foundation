class Message < ActiveRecord::Base
  attr_accessible :content, :subject
  belongs_to :message_thread
end
