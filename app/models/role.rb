class Role < ActiveRecord::Base
  attr_accessible :title, :started, :ended
  belongs_to :user
  belongs_to :startup
end
