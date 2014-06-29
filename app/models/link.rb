class Link < ActiveRecord::Base
  attr_accessible :href, :title
  belongs_to :owner, polymorphic: true
end
