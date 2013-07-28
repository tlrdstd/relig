require 'tweetstream'
TweetStream.configure do |config|
  config.consumer_key       = ENV['RELIG_CONSUMER_KEY']
  config.consumer_secret    = ENV['RELIG_CONSUMER_SECRET']
  config.oauth_token        = ENV['RELIG_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['RELIG_OAUTH_TOKEN_SECRET']
end
