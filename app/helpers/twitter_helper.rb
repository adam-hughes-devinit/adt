module TwitterHelper
  def search_twitter_ajax
    #Settings for Twitter Gem
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = '222QB6PPCTVm6mQrcEuQXApzh'
      config.consumer_secret = 'bHLDJs8ZNr2s4AbzGmHhkNtB7VBoU9Z3DCo9vz6wjxpceBMEdv'
    end
    @tweetBucket = []
    client.search(params["search"], :geocode=>"1.9033,16.5235,11100km", :result_type => "recent").take(50).each do |tweet|
      tweetObj = {}
      tweetObj["text"] = tweet.text
      tweetObj["author"] = tweet.user.name
      tweetObj["handle"] = tweet.user.screen_name
      unless tweet.place.nil?
        tweetObj["geoname"] = tweet.place.full_name
      else
        tweetObj["geoname"] = tweet.user.location
      end
      unless tweet.geo.nil?
        tweetObj["latLng"] = tweet.geo.coordinates
      else
        tweetObj["latLng"] = nil
      end
      @tweetBucket << tweetObj
    end
    render :json => @tweetBucket.flatten
  end
end