require 'link_resolver'
require 'title_map'
require 'parallel'
require 'result_presenter'
require 'logger'

class StatisticsCollator
  NUM_THREADS = 20

  attr_reader :tweets, :link_resolver, :title_map, :link_counts, :result_presenter_factory, :logger

  def initialize(tweets, result_presenter_factory: nil, link_resolver: nil, title_map: nil, logger: Logger.new(STDERR))
    @tweets = tweets
    @link_resolver = link_resolver || LinkResolver.new
    @title_map = title_map || TitleMap.new
    @result_presenter_factory = result_presenter_factory ||
      ->(tweet) { ResultPresenter.new(tweet, link_resolver: link_resolver, title_map: title_map) }
    @link_counts = {}
    @logger = logger
  end

  def collate
    i = 0
    logger.info "Collating tweets in #{NUM_THREADS} threads"

    Parallel.each(tweets, in_threads: NUM_THREADS) do |tweet|
      i += 1
      presenter = result_presenter_factory.call(tweet)
      presenter.links_with_titles.each do |link_with_title|
        count(link_with_title, presenter.screen_name)
      end

      if (i % 20) == 0
        logger.info "Processing tweet number #{i}, found #{link_counts.size} links so far"
      end
    end
    logger.info "Finished. Found #{link_counts.size} links."
    link_counts.sort_by {|url, l| -l[:count] }
  end

  def count(link_with_title, screen_name)
    url,title = link_with_title
    if link_counts.has_key?(url)
      link_counts[url][:count] += 1
      link_counts[url][:recommended_by] << screen_name
    else
      link_counts[url] = {
        title: title,
        count: 1,
        recommended_by: [screen_name]
      }
    end
  end
end
