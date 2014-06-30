class Startup < ActiveRecord::Base
  attr_accessible :name, :company_size, :image, :angellist_quality, :description, :byline, :follower_count, :confirmed, :phone_number
  has_one :address, as: :addressable, :dependent => :destroy
  has_many :links, as: :owner, :dependent => :destroy
  has_many :roles
  has_many :users, through: :roles
  has_and_belongs_to_many :markets
end
