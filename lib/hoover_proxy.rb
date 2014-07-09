class HooverProxy < Scraper
  def initialize
    super('http://www.hoovers.com/company-information/')
  end

  def validate_company(company)
    page = get_page("company-search.html?term=#{CGI::escape(company)}")
    
    # Get list of all links on search results
    array_of_links = page.links_with(:text => Regexp.new(company, true))
    return nil if array_of_links.empty? # no results found that match what we're looking for

    # Click on the first match, since it should be the best match
    link = array_of_links.first
    page = @agent.get(link.href)

    # Parse page and return standardized data
    page_content = Nokogiri::HTML(page.content)
    {
      :name => link.text.strip,
      :address => {
        :street => page_content.xpath('//span[@itemprop="streetAddress"]').text.strip,
        :city => page_content.xpath('//span[@itemprop="addressLocality"]').first.text.strip,
        :state => page_content.xpath('//span[@itemprop="addressRegion"]').first.text.strip,
        :country => page_content.xpath('//span[@itemprop="addressCountry"]').first.text.strip,
      },
      :phone_number => page_content.xpath('//span[@itemprop="telephone"]').first.text.strip,
      :tags => page_content.xpath('//div[@class="tag-container"]/a[@class="tag"]').map {|tag| tag.text.strip}
    }
  end

  def validate_user(user, company)
    page = get_page("cs/people-search.html?term=#{CGI::escape(user)}%20#{CGI::escape(company)}")

    # Get list of all links on search results
    array_of_links = page.links_with(:text => Regexp.new(user, true))
    return nil if array_of_links.empty? # no results found that match what we're looking for

    # Parse page and return standardized data
    page_content = Nokogiri::HTML(page.content)
    {
      :name => array_of_links.first.text.strip, # Choose the first match, since it should be the best match
      :title => page_content.xpath('//*[@id="shell"]/div/div/div[2]/div[3]/div/div/div[1]/table/tbody/tr[1]/td[2]').text.strip,
      :company => page_content.xpath('//*[@id="shell"]/div/div/div[2]/div[3]/div/div/div[1]/table/tbody/tr[1]/td[3]').text.strip
    }
  end

  def validate(company, user = nil)
    validated_user = user ? validate_user(user, company) : nil
    {
      :user => validated_user,
      :company => validate_company(validated_user.try(:[], :company) || company)
    }
  end
end
