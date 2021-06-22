# frozen_string_literal: false

require 'kimurai'
require 'json'

class EloScraper < Kimurai::Base
  @@main_url = 'https://www.superbad.com/1/'
  @@visited = []
  @@unvisited = []

  @name = 'elos_scraper'
  @start_urls = ["#{@@main_url}wallpaper/index.html"]
  @engine = :selenium_firefox

  @@json = []

  def scrape_page
    title = browser.title
    return if title == 'żlucha?'

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
      href = a.get_attribute('href')
      href = href.gsub('../', '').gsub('/1/', '') if href
      link = "#{@@main_url}#{href}"
      next if @@visited.include?(link) || @@unvisited.include?(link)

      @@unvisited.append(link)
    end
    puts "UNVISITEDUNVISITEDUNVISITEDUNVISITEDUNV #{@@unvisited}"
    @@json << page
  end

  def parse(response, url:, data: {})
    scrape_page

    #50.times do
    while @@unvisited.count.positive?
      browser.visit @@unvisited.pop
      scrape_page
    end

    File.open('2000.json', 'w') do |f|
      f.write(JSON.pretty_generate(@@json))
    end

  end
end
EloScraper.crawl!
