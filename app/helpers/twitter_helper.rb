module TwitterHelper
  def search_twitter_ajax
    #Settings for Twitter Gem
    client = Twitter::Streaming::Client.new do |config|

    end
    client.filter(:locations => "-122.75,36.8,-121.75,37.8") do |tweet|
      puts tweet.text
    end
  end
end