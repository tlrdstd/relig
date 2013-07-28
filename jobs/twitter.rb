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
    @store << tweet.created_at
  end

  def count
    one_hour_ago = Time.now - 3600
    @store.count{|timestamp| timestamp >= one_hour_ago}
  end

  def purge
    one_hour_ago = Time.now - 3600
    @store.delete_if{|timestamp| timestamp < one_hour_ago}
  end
end

logger = Logger.new(File.join(Dir.pwd, 'logs', 'relig.log'), 'daily')
@jobs = {}
TwitterJob::TERMS.map(&:downcase).each do |term|
  @jobs[term] = TwitterJob.new(term)
end

SCHEDULER.every '1s' do
  @jobs.each_pair do |name, job|
    send_event(name, {current: job.count})
  end
end

SCHEDULER.in '5s' do
  client = TweetStream::Client.new
  client.on_error do |message|
    logger.error "ERROR!!!! #{message}"
  end
  client.on_limit do |skip_count|
    logger.info "HIT RATE LIMIT: #{skip_count}"
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

SCHEDULER.every '2h' do
  @jobs.each(&:purge)
end
