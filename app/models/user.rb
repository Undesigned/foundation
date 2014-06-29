class User < ActiveRecord::Base
  attr_accessible :name, :email, :bio, :follower_count, :investor, :image, :location, :what_ive_built, :what_i_do, :criteria
  attr_readonly :provider, :uid
  has_many :links, as: :owner, :dependent => :destroy
  has_many :roles
  has_many :startups, through: :roles
  has_and_belongs_to_many :skills
  has_many :tokens, :dependent => :destroy
  has_many :searches, :dependent => :destroy
  has_and_belongs_to_many :message_threads

  before_save { |user| user.email = email.downcase }

  VALID_EMAIL_REGEX = /\A.+@.+\.[a-z]+\z/i

  validates :name, :presence => true
  validates :email, :presence => true,
            :format   => { :with => VALID_EMAIL_REGEX },
            :uniqueness => { :case_sensitive => false }

  def import_data(provider)
    case provider
    when 'angellist' then import_from_angellist
    else
      raise Exceptionally::BadRequest.new("Provider #{provider} not recognized")
    end
  end

  def import_from_angellist
    api = AngellistApi::Client.new(:access_token => tokens.where(provider: 'angellist').first!)
    result = api.me

    # Save attributes
    self.update_attributes!({
      :name => result['name'],
      :bio => result['bio'],
      :follower_count => result['follower_count'],
      :image => result['image'],
      :what_ive_built => result['what_ive_built'],
      :what_i_do => result['what_i_do'],
      :criteria => result['criteria'],
      :location => result['locations'][0]['display_name'],
      :investor => result['investor']
    }.delete_if{|k,v| v.blank?})

    # Save links
    result.each_pair do |key, val|
      if key =~ /_url$/
        title = key.gsub(/_url$/, '')
        link = links.where(title: title).first
        if link
          link.href = val
          link.save!
        else
          links.create!(title: title, href: val)
        end
      end
    end

    # Save skills
    result['skills'].each {|skill| skills << Skill.find_or_create_by!(name: skill['display_name']) unless skills.where(name: skill['display_name']).exists? }

    # Get all startups tagged with this user
    startups = []
    roles = api.user_roles(uid)
    while roles['page'] <= roles['last_page']
      startups.concat(roles['startup_roles'])
      roles = api.user_roles(uid, {:page => roles['page'] + 1}) unless roles['page'] == roles['last_page']
    end

    # Save startups
    startups.each do |role|
      # We don't care about startups this user did not found
      next if role['role'] != 'founder'

      startup = role['startup']

      # TODO confirm that this startup is incorporated and that this user is on the incorporation docs

      s = startups.where(name: startup['name'])
      if s
        r = roles.where(startup: s).first
        r.title = role['title']
        r.started = role['started_at'].to_date
        r.ended = role['ended_at'].try(:to_date)
        r.save!
      else
        r = roles.create!(title: role['title'], started: role['started_at'].to_date, ended: role['ended_at'].try(:to_date))
      end
      
      su = api.get_startup(startup['id'])
      image_url = su.delete('logo_url')
      su.delete('thumb_url')
      if s
        s.update_attributes!({
          name: su['name'],
          image: image_url,
          angellist_quality: su['quality'],
          description: su['product_desc'],
          byline: su['high_concept'],
          follower_count: su['follower_count'],
          company_size: su['company_size']
        }.delete_if{|k,v| v.blank?})
      else
        s = r.startup.create!({
          name: su['name'],
          image: image_url,
          angellist_quality: su['quality'],
          description: su['product_desc'],
          byline: su['high_concept'],
          follower_count: su['follower_count'],
          company_size: su['company_size']
        })
      end

      # Save links
      su.each_pair do |key, val|
        if key =~ /_url$/
          title = key.gsub(/_url$/, '')
          link = s.links.where(title: title).first
          if link
            link.href = val
            link.save!
          else
            s.links.create!(title: title, href: val)
          end
        end
      end

      # Save markets
      startup['markets'].each {|m| s.markets << Market.find_or_create_by!(name: m['display_name']) unless s.markets.where(name: m['display_name']).exists? }
    end
  end
end
