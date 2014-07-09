class MetaData < ActiveRecord::Base
  attr_accessible :name, :value, :source
  belongs_to :owner, polymorphic: true
end
