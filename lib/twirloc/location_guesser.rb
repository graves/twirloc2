module Twirloc
  class LocationGuesser
    attr_reader :username, :client
    #@profile_location = user_profile_location(username) X
    #@geolocations_of_tweets = user_tweet_geolocations(username)
    #@geolocations_of_followers_tweets = follower_tweet_geolocations(username)
    #@geolocations_of_followings_tweets = following_tweet_geolocations(username)
    #avg_follow = avg_follow_locations(@geolocations_of_followers_tweets, @geolocations_of_followings_tweets)

    def initialize(username)
      @username ||= username
      @client ||= TwitterClient.new
    end

    def user_tweets_geolocation_center
      # Geographic centerpoint of users geolocation metadata from tweets
      coordinates = user_tweets_with_geolocation.map { |t| t.coordinates }
      return "No tweets with geolocation!" if coordinates.empty?
      midpoint = MidpointCalculator.calculate(coordinates)
      GoogleLocation.new(coords: midpoint).to_s
    end

    def user_profile_location
      # String from top of users profile indicating location
      client.user(username).location || ""
    end

    def user_tweets_with_geolocation
      geo_tweets = geo_only(TweetFetcher.new(client, username).fetch_all_tweets)
      wrap_tweets(geo_tweets)
    end

    private

    def geo_only(tweets)
      tweets.select { |t| t.geo? }
    end

    def wrap_tweets(tweets)
      tweets.map { |t| Tweet.new(t) }
    end

  end
end
