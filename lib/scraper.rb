class Scraper

  def initialize(base_url = '')
    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Windows IE 7'
    }
    @base_url = base_url
  end

  #returns a web page
  def get_page(url)
    @agent.get("#{@base_url}#{url}")
  end
end
