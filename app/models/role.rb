class Role < ActiveRecord::Base
  attr_accessible :title, :started, :ended, :confirmed
  belongs_to :user
  belongs_to :startup

  scope :recent, -> { where("ended is null or ended > now() - interval '2 years'") }
end
