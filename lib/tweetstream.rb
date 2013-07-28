require 'tweetstream'
require 'yaml'

auth = YAML.load(File.read('config/twitter.yml'))
TweetStream.configure do |config|
  auth.each_pair do |name, value|
    config.send("#{name}=", value)
  end
end
