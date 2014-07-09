class AngellistProxy < Scraper

  # The Angellist API doesn't give us funding status for some reason, so let's try to scrape it instead
  def get_funding(url)
    page = @agent.get(url)
    page_content = Nokogiri::HTML(page.content)

    return nil unless page_content.xpath('//div[@class="header past_financing"]').first.try(:text) =~ /Funding/i

    {
      stage: page_content.xpath('//div[@class="past_financing section"]/div/ul[@class="startup_rounds with_rounds"]/li/div/div/div[1]/div[1]/div[1]').first.try(:text).try(:strip),
      total_funding: page_content.xpath('//div[@class="past_financing section"]/div/ul[@class="startup_rounds with_rounds"]/li/div/div/div[1]/div[2]/a').first.try(:text).try(:strip).try(:gsub, /[$,]/, '').try(:to_i),
      investors: page_content.xpath('//div[@class="past_financing section"]/div/div[@class="group"]/div/ul/li/div/div/div[2]/div/a').map {|name| name.text.strip}
    }
  end
end
