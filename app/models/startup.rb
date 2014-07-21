class Startup < ActiveRecord::Base
  attr_accessible :name, :company_size, :image, :description, :byline, :confirmed, 
                  :phone_number, :total_funding, :number_of_investments, :funding_stage
  has_one :address, as: :addressable, :dependent => :destroy
  has_many :links, as: :owner, :dependent => :destroy
  has_many :meta_data, as: :owner, :dependent => :destroy
  has_many :roles
  has_many :users, through: :roles
  has_and_belongs_to_many :markets

  def standardized_company_size
    case company_size.split('-').last.to_i
    when 0..10 then '1-10'
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

  def add_market(market)
    markets << Market.find_or_create_by!(name: market) unless markets.exists?(name: market)
  end

  def set_address(addr)
    address ? address.update_attributes!(addr) : create_address!(addr)
  end
end
