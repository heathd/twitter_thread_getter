require 'link_resolver'

RSpec.describe LinkResolver do

  subject(:link_resolver) { LinkResolver.new }

  before do
    url_map = {
      "https://t.co/URJSWdMCW2" => "https://youtu.be/xx7Lfh5SKUQ",
      "https://t.co/HNMxIJXP56" => "https://www.infoq.com/presentations/Simple-Made-Easy/"
    }

    url_map.each do |from_url, to_url|
      res = Net::HTTPMovedPermanently.new nil, '301', nil
      res.add_field 'Location', to_url

      allow(Net::HTTP).to receive(:get_response).with(URI.parse(from_url)).and_return(res)
    end
  end

  it "resolves a link" do
    expect(link_resolver.resolve("https://t.co/URJSWdMCW2")).to eq("https://youtu.be/xx7Lfh5SKUQ")
  end
end
