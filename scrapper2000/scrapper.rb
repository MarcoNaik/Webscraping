# frozen_string_literal: false

require 'kimurai'
require 'json'

class EloScraper < Kimurai::Base
  @@main_url = 'https://eloisa2000.net/'
  @@visited = []
  @@unvisited = []

  @name = 'elos_scraper'
  @start_urls = ["#{@@main_url}caminar.html"]
  @engine = :selenium_firefox

  @@json =[]

  def scrape_page
    title = browser.title
    url = browser.current_url
    doc = browser.current_response
    p = doc.css('p').text.gsub(/\n/, '').split.join(' ')
    links = doc.css('a')
    @img = ''

    imgs = doc.css('img')
    imgs.each do |i|
      @img = i.get_attribute('src')
    end

    page = { title: title, url: url, description: p, links: links.text.gsub(/\n/, '').split.join(' '), images: @img }

    @@visited.append(url)

    links.each do |a|
      link = "#{@@main_url}#{a.get_attribute('href')}"
      @@unvisited.append(link) unless @@visited.zip(@@unvisited).flatten.compact.include? link
    end
    @@json << page
  end

  def parse(response, url:, data: {})
    scrape_page

    while @@unvisited.count.positive?
      browser.visit @@unvisited.pop
      scrape_page
    end

    @@visited.reject { |u| u.empty? }

    File.open('2000.json', 'w') do |f|
      f.write(JSON.pretty_generate(@@json))
    end

  end
end
EloScraper.crawl!
