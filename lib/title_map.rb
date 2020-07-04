require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'parallel'

class TitleMap
  attr_reader :url_map

  def initialize
    @url_map = {}
  end

  def add(urls)
    Parallel.map(urls, in_threads: 20) do |url|
      url_map[url] ||= fetch_title(url)
    end
  end

  def title(url)
    url_map[url] ||= fetch_title(url)
  end

private
  def fetch_title(url)
    data = open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |f| f.read }
    html_doc = Nokogiri::HTML(data)
    youtube_title = html_doc.xpath("//meta[@name='title']/@content")
    if youtube_title.size > 0
      youtube_title.to_s
    else
      html_doc.css("title").inner_text
    end
  rescue Errno::ECONNRESET,Errno::ECONNREFUSED,OpenURI::HTTPError => e
    e.to_s
  end
end
