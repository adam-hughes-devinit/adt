module TwitterHelper
  def search_twitter_ajax
    #Settings for Twitter Gem
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = 'oops'
      config.consumer_secret = 'oops'
    end
    @tweetBucket = []
    client.search("fifa", :result_type => "recent").take(5000000).each do |tweet|
      unless tweet.geo.nil?
        tweetObj = {}
        tweetObj["text"] = tweet.text
        tweetObj["author"] = tweet.user.name
        tweetObj["handle"] = tweet.user.screen_name
        unless tweet.place.nil?
          tweetObj["geoname"] = tweet.place.full_name
        else
          tweetObj["geoname"] = nil
        end
        tweetObj["latLng"] = tweet.geo.coordinates
        @tweetBucket << tweetObj
      end
    end
    render :json => @tweetBucket
  end
end