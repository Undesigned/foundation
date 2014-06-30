class Role < ActiveRecord::Base
  attr_accessible :title, :started, :ended, :confirmed
  belongs_to :user
  belongs_to :startup
end
