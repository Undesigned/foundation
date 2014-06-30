class Link < ActiveRecord::Base
  attr_accessible :href, :title
  belongs_to :owner, polymorphic: true

  # Return stylized titles 
  def title
    t = read_attribute(:title)
    return case t
    when 'angellist' then 'AngelList'
    when 'linkedin' then 'LinkedIn'
    when 'aboutme' then 'About.me'
    when 'github' then 'GitHub'
    else t.titleize
    end
  end
end
