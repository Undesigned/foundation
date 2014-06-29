class Token < ActiveRecord::Base
  attr_accessible :provider, :content
  belongs_to :user

  validates :provider, :presence => true
  validates :content, :presence => true
  validates :user, :presence => true
end
