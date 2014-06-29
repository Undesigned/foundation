class Address < ActiveRecord::Base
  attr_accessible :street, :street2, :city, :state, :zip
  belongs_to :addressable, polymorphic: true

  validates :city, :presence => true
  validates :state, :length => { is: 2 }
end
