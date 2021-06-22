require 'kimurai'
require 'json'

class Scrapper < Kimurai::Base
  @name = 'platanus_blog_scrapper'
  @start_urls = ['https://plata.news/blog/']
  @engine = :selenium_firefox

  @@urls= []
  @@json = []

  def get_blog_urls
    @@urls << browser.current_response.xpath("//article/div/a[contains(@class, 'm-article-card__info-link')]/@href")
  end

  def next_page
    browser.find(:css, '.in-pagination-right span').click
  end

  def scrap_blog(url)
    browser.visit "https://plata.news/#{url}"
    response = browser.current_response

    title = response.xpath("//h1").text
    tag = response.xpath("//a[contains(@class, 'm-heading__meta__tag')]").text
    date = response.xpath("//span[contains(@class, 'm-heading__meta__time')]").text
    author = response.xpath("//h4[contains(@class, 'm-author__name')]/a").text
    text = response.xpath("//div[contains(@class, 'js-post-content')]/p").text

    page = { title: title, author: author, date: date, tag: tag, text: text }

    @@json << page
  end

  def parse(response, url:, data: {})
    get_blog_urls
    8.times do
      next_page
      get_blog_urls
    end

    @@urls.each do |lol|
      lol.each do |xd|
        scrap_blog(xd)
      end
    end
    File.open('blog.json', 'w') do |f|
      f.write(JSON.pretty_generate(@@json))
    end
  end
end

Scrapper.crawl!
