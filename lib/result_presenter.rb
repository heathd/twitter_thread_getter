require 'csv'
require 'net/http'
require 'uri'
require 'link_resolver'

class ResultPresenter
  attr_reader :result, :link_resolver, :title_map

  def initialize(result, link_resolver: nil, title_map: nil)
    @result = result
    @resolver_cache = {}
    @link_resolver = link_resolver || LinkResolver.new
    @title_map = title_map || TitleMap.new
  end

  def screen_name
    result.attrs[:user][:screen_name]
  end

  def in_reply_to_status_id
    result.in_reply_to_status_id
  end

  def text
    result.full_text.gsub("\n", " ").gsub(%r{https://t.co/[^\s\.]*}) do |match|
      link_resolver.resolve(match)
    end
  end

  def links
    result.full_text.scan(%r{https://t.co/[^\s\.]*})
  end

  def expanded_links
    links.map {|l| link_resolver.resolve(l)}
  end

  def links_with_titles
    expanded_links.map {|link| [link, title_map.title(link)] }
  end

  def field_map
    {
      in_reply_to_status_id: in_reply_to_status_id,
      screen_name: screen_name,
      text: text,
      links_with_titles: links_with_titles
    }
  end

  def present
    fields = [in_reply_to_status_id, screen_name, text]
    (fields + expanded_links).to_csv
  end
end
