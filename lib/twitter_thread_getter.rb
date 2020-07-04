require 'twitter'
require 'pp'
require 'yaml'

class TwitterThreadGetter
  attr_reader :thread_id, :client, :config_file

  def initialize(thread_id, client: nil)
    @thread_id = thread_id
    @config_file = ENV["HOME"] + "/.trc"
    @client = client || default_client
  end

  def default_client
    raise "Twitter secrets file #{config_file} missing. Please authorise as per https://github.com/sferik/t#configuration" unless File.exist?(config_file)
    config = YAML.load(File.read(config_file))
    path = config['configuration']['default_profile']
    params = path.inject(config['profiles']) do |memo, elem|
      memo[elem]
    end

    Twitter::REST::Client.new do |config|
      config.consumer_key        = params['consumer_key']
      config.consumer_secret     = params['consumer_secret']
      config.access_token        = params['token']
      config.access_token_secret = params['secret']
    end
  end

  def get
    orig_tweet = client.status(thread_id)

    user = orig_tweet.attrs[:user][:screen_name]
    client.search("to:#{user}", since_id: thread_id, count: 10, result_type: "recent", tweet_mode: "extended")
  end
end
