require 'yaml'
require 'logger'

class TwitterJob
  TERMS = YAML.load(File.read('config/terms.yml'))
  REGEX = /#{TERMS.join '|'}/i

  def self.match tweet
    REGEX.match(tweet).to_s.downcase
  end

  def initialize job_name
    @store = []
    @name  = job_name
  end

  def remember tweet
    @store << {
      timestamp: tweet.created_at,
      name: tweet.user.name,
      body: tweet.text,
      avatar: tweet.user.profile_image_url_https
    }
  end

  def count
    @store.size
  end

  def purge
    one_hour_ago = Time.now - 3600
    @store.delete_if{|tweet| tweet[:timestamp] < one_hour_ago}
  end
end

logger = Logger.new(STDOUT)
@jobs = {}
TwitterJob::TERMS.map(&:downcase).each do |term|
  @jobs[term] = TwitterJob.new(term)
end

SCHEDULER.in '5s' do
  client = TweetStream::Client.new
  client.on_error do |message|
    logger.error message
  end
  client.on_enhance_your_calm do
    logger.warn "I am NOT ENHANCING MY CALM!!"
  end
  client.track(TwitterJob::TERMS) do |tweet|
    term = TwitterJob.match(tweet.text)
    if term && !term.empty?
      @jobs[term].remember tweet
    end
  end
end

SCHEDULER.every '10s' do
  @jobs.each_pair do |name, job|
    store = job.instance_variable_get(:@store)
    send_event("#{name}-list", {comments: store[-10..-1] || store})
  end
end

SCHEDULER.every '1s' do
  @jobs.each_pair do |name, job|
    send_event(name, {current: job.count})
  end
end

SCHEDULER.every '1m' do
  @jobs.each_pair do |name, job|
    job.purge
  end
end
