class MessageThread < ActiveRecord::Base
  attr_accessible :uid
  has_many :messages
  has_and_belongs_to_many :users
end
