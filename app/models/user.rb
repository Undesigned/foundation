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
    result = AngellistApi.get_user(uid)

    # Save attributes
    self.update_attributes!({
      name: result['name'],
      bio: result['bio'],
      follower_count: result['follower_count'],
      image: result['image'],
      what_ive_built: result['what_ive_built'],
      what_i_do: result['what_i_do'],
      criteria: result['criteria'],
      location: result['locations'][0]['display_name'],
      investor: result['investor']
    }.delete_if{|k,v| v.blank?})

    # Save links
    result.each_pair do |key, val|
      next if (key =~ /_url$/).nil? || val.blank?
      link = links.find_or_initialize_by(title: key.gsub(/_url$/, ''))
      link.href = val
      link.save!
    end

    # Save skills
    result['skills'].each {|skill| skills << Skill.find_or_create_by!(name: skill['display_name']) unless skills.where(name: skill['display_name']).exists? } if result['skills']

    # Get all startups tagged with this user
    startup_list = []
    roles_pages = AngellistApi.user_roles(uid)
    while roles_pages['page'] < roles_pages['last_page']
      # There's more pages, loop through and get them all
      startup_list.concat(roles_pages['startup_roles'])
      roles_pages = AngellistApi.user_roles(uid, {:page => roles_pages['page'] + 1})
    end
    startup_list.concat(roles_pages['startup_roles']) # concat the last page

    # Save startups
    startup_list.each do |role|
      # We don't care about startups this user did not found
      next if role['role'] != 'founder'

      startup = role['startup']

      # Confirm that this startup is incorporated and that this user is on the incorporation docs
      hoover_validations = HooverProxy.new.validate(startup['name'], name)
      startup_name = hoover_validations[:company].try(:[], :name) || startup['name']

      # Set this user's role in the startup
      user_hsh = {
        title: hoover_validations[:user].try(:[], :title) || role['title'],
        started: role['started_at'].to_date,
        ended: role['ended_at'].try(:to_date),
        confirmed: !hoover_validations[:user].nil?
      }.delete_if{|k,v| v.blank?}
      s = startups.where(name: startup_name).first
      if s
        r = roles.where(startup: s).first
        r.assign_attributes(user_hsh)
      else
        r = roles.build(user_hsh)
      end
      
      # Update or create the startup
      su = AngellistApi.get_startup(startup['id'])
      image_url = su.delete('logo_url')
      su.delete('thumb_url')
      startup_hsh = {
        name: startup_name,
        image: image_url,
        angellist_quality: su['quality'],
        description: su['product_desc'],
        byline: su['high_concept'],
        follower_count: su['follower_count'],
        company_size: su['company_size'],
        confirmed: !hoover_validations[:company].nil?,
        phone_number: hoover_validations[:company].try(:[], :phone_number)
      }.delete_if{|k,v| v.blank?}
      s ? s.update_attributes!(startup_hsh) : s = r.create_startup!(startup_hsh)

      # Add address to startup
      if hoover_validations[:company]
        if s.address
          s.address.update_attributes!(hoover_validations[:company][:address])
        else
          s.create_address!(hoover_validations[:company][:address])
        end
      end

      # Save role
      r.save!

      # Save links for startup
      su.each_pair do |key, val|
        next if (key =~ /_url$/).nil? || val.blank?
        link = s.links.find_or_initialize_by(title: key.gsub(/_url$/, ''))
        link.href = val
        link.save!
      end

      # Save markets for startup
      startup['markets'].each {|m| s.markets << Market.find_or_create_by!(name: m['display_name']) unless s.markets.where(name: m['display_name']).exists? } if startup['markets']
      hoover_validations[:company][:tags].each {|tag| s.markets << Market.find_or_create_by!(name: tag) unless s.markets.where(name: tag).exists? } if hoover_validations[:company]
    end
  end
end
