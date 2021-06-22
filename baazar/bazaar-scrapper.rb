# baazar-scrapper.rb
require 'kimurai'

class Scrapper < Kimurai::Base
  @name = "baazar_scrapper"
  @engine = :selenium_firefox
  @start_urls = ['https://playthebazaar.com']

  @@main_url = 'https://playthebazaar.com'

  @@json = []

  @@next_page = ""

  def parse(response, url:, data: {})

    request_to :parse_page, url: "#{url}/blogs/news"

    10.times do
      request_to :parse_page, url: "#{url}#{@@next_page.attr('href')}"
    end

    File.open('blog_posts.json', 'w') do |f|
      f.write(JSON.pretty_generate(@@json))
    end
  end

  def parse_page(response, url:, data: {})
    @@next_page = response.xpath("//span[@class ='next']/a")
    puts @@next_page
    response.xpath("//div[contains(@class, 'grid__item')]/a").each do |a|
      request_to :parse_post_page, url: "#{@@main_url}#{a.attr('href')}"
    end
  end

  def parse_post_page(response, url:, data: {})
    item = {}

    item[:date] = response.xpath('//time').text
    item[:title] = response.xpath("//h1[@class='section-header__title']").text
    article_body = response.xpath("//div[contains(@class, 'article__body')]")
    item[:text] = article_body.xpath('//p|//blockquote').text
    if (link = response.xpath("//a[contains(@class, 'ytp-title-link')]"))
      item[:link] = link
    end
    @@json << item
  end
end

Scrapper.crawl!
