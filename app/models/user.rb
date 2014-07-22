class User < ActiveRecord::Base
  attr_accessible :name, :email, :bio, :investor, :image, :location, 
                  :what_ive_built, :what_i_do, :criteria, :birthyear, 
                  :technical_points, :design_points, :business_points
  attr_readonly :provider, :uid
  has_many :links, as: :owner, :dependent => :destroy
  has_many :roles
  has_many :startups, through: :roles
  has_many :meta_data, as: :owner, :dependent => :destroy
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

  searchable(include: [{roles: {startups: :markets}}, :skills], ignore_attribute_changes_of: [:email, :image]) do
    text :name, :location, :bio, :what_ive_built, :what_i_do, :criteria
    text :startup_names do
      startups.pluck(:name)
    end
    text :startup_bylines do
      startups.pluck(:byline)
    end
    text :startup_descriptions do
      startups.pluck(:description)
    end
    text :skills do
      skills.pluck(:name)
    end
    text :markets do
      startups.map { |startup| startup.markets.pluck(:name) }.flatten
    end
    string :max_company_size
    integer :total_startup_years
    integer :startup_count do
      startups.count
    end
    integer :technical_points
    integer :design_points
    integer :business_points
    integer :age
    boolean :investor
    boolean :funded
  end

  def age
    birthyear ? Time.now.year - birthyear : nil
  end

  def funded
    startups.exists?("total_funding > 0 or number_of_investments > 0")
  end

  def total_startup_years
    max_year, min_year = roles.map{|role| [(role.ended || Time.now).year, role.started.year]}.transpose
    max_year = max_year.try(:max)
    min_year = min_year.try(:min)
    max_year && min_year ? max_year - min_year : 0
  end

  def max_company_size
    case startups.map {|startup| startup.company_size.split('-').last.to_i}.max
    when 0, nil then nil
    when 1..10 then '1-10'
    when 11..50 then '11-50'
    when 51..200 then '51-200'
    when 201..500 then '201-500'
    else '500+'
    end
  end

  def save_meta_data(name, value, source)
    md = meta_data.find_or_initialize_by(name: name, source: source)
    md.value = value.to_s
    md.save!
  end

  def save_link(title, url)
    link = links.find_or_initialize_by(title: title)
    link.href = url
    link.save!
  end

  def add_skill(skill)
    skills << Skill.find_or_create_by!(name: skill) unless skills.exists?(name: skill)
  end

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
    self.assign_attributes({
      name: result['name'],
      bio: result['bio'],
      image: result['image'],
      what_ive_built: result['what_ive_built'],
      what_i_do: result['what_i_do'],
      criteria: result['criteria'],
      location: result['locations'][0]['display_name'],
      investor: result['investor']
    }.delete_if{|k,v| v.blank?})

    # Save angellist follower count
    save_meta_data('follower_count', result['follower_count'], 'angellist') if result['follower_count']

    # Save links
    result.each_pair {|key, val| save_link(key.gsub(/_url$/, ''), val) if key =~ /_url$/ && val}

    # Save skills
    result['skills'].each {|skill| add_skill(skill['display_name']) } if result['skills']
    result['roles'].each {|skill| add_skill(skill['display_name']) } if result['roles']

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
      funding = AngellistProxy.new.get_funding(su['angellist_url']) || {}
      startup_hsh = {
        name: startup_name,
        image: image_url,
        description: su['product_desc'],
        byline: su['high_concept'],
        company_size: su['company_size'],
        confirmed: !hoover_validations[:company].nil?,
        phone_number: hoover_validations[:company].try(:[], :phone_number),
        total_funding: funding[:total_funding],
        number_of_investments: funding[:investors].try(:length),
        funding_stage: funding[:stage]
      }.delete_if{|k,v| v.blank?}
      s ? s.update_attributes!(startup_hsh) : s = r.create_startup!(startup_hsh)
      r.save!

      # Save angellist startup follower count and quality rating
      s.save_meta_data('follower_count', su['follower_count'], 'angellist') if su['follower_count']
      s.save_meta_data('quality', su['quality'], 'angellist') if su['quality']

      # Add address to startup
      s.set_address(hoover_validations[:company][:address]) if hoover_validations[:company]

      # Save links for startup
      su.each_pair {|key, val| s.save_link(key.gsub(/_url$/, ''), val) if key =~ /_url$/ && val}

      # Save markets for startup
      su['markets'].each {|m| s.add_market(m['display_name']) } if su['markets']
      hoover_validations[:company][:tags].each {|tag| s.add_market(tag) } if hoover_validations[:company]
    end

    # save and reindex
    self.save!
  end
end
