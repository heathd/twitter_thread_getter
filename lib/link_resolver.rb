require 'net/http'
require 'uri'

class LinkResolver
  def initialize
    @resolver_cache = {}
  end

  def resolve(link)
    @resolver_cache[link] ||= begin
      response = Net::HTTP.get_response(URI.parse(link))
      if response.code == '301'
        response['Location']
      else
        link
      end
    end
  end
end
