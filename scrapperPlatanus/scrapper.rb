require 'kimurai'
require 'json'

class Scrapper < Kimurai::Base
  @name = 'platanus_team_scrapper'
  @start_urls = ['https://platan.us/team']
  @engine = :selenium_firefox

  def parse(response, url:, data: {})
    cards = response.css('.the-team__members li')
    json = []
    cards.each do |c|
      name = c.css('h1').text
      job = c.css('h2').text
      links = c.css('div a')
      links_json =  {}
      links.each do |l|
        url = l.get_attribute('href')
        domain = l.css('svg title').text.strip!
        links_json[domain] = url
      end
      json << { name: name, job: job, links: links_json }
    end
    File.open('team.json', 'w') do |f|
      f.write(JSON.pretty_generate(json))
    end
  end
end

Scrapper.crawl!
