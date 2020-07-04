require "result_presenter"

RSpec.describe ResultPresenter do
  MockResult = Struct.new(:attrs, :in_reply_to_status_id, :full_text)

  let(:full_text) { "Bar" }

  let(:result) {
    MockResult.new({user: {screen_name: "Foo"}}, 123, full_text)
  }

  subject(:result_presenter) {
    ResultPresenter.new(result)
  }

  it "presents it as a CSV row" do
    expect(result_presenter.present).to eq("123,Foo,#{full_text}\n")
  end

  describe "Link resolution" do
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

    context "when the full text has two links" do
      let(:full_text) {
        "Nice talk https://t.co/URJSWdMCW2 https://t.co/HNMxIJXP56"
      }

      it "extracts the links" do
        expect(result_presenter.links).to eq(["https://t.co/URJSWdMCW2", "https://t.co/HNMxIJXP56"])
      end

      it "resolves the links" do
        expect(result_presenter.present).to eq("123,Foo,Nice talk https://youtu.be/xx7Lfh5SKUQ https://www.infoq.com/presentations/Simple-Made-Easy/,https://youtu.be/xx7Lfh5SKUQ,https://www.infoq.com/presentations/Simple-Made-Easy/\n")
      end

      it "expands links" do
        expect(result_presenter.expanded_links).to eq(["https://youtu.be/xx7Lfh5SKUQ","https://www.infoq.com/presentations/Simple-Made-Easy/"])
      end
    end
  end
end
