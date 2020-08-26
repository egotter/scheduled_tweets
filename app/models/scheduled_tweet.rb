class ScheduledTweet < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :text, presence: true
  validates :time, presence: true

  MAX_TWEETS = 100

  validate on: :create do
    if user.scheduled_tweets.not_published.size >= MAX_TWEETS
      errors.add(:base, I18n.t('activerecord.errors.messages.too_many_not_published_tweets', count: MAX_TWEETS))
    end

    unless TextValidator.new(text).valid?
      errors.add(:text, :text_too_long)
    end

    if text.to_s.include?('*')
      errors.add(:text, :text_invalid)
    end
  end

  after_create_commit do
    CreateTweetWorker.perform_at(time, id, user_id: user.id, text: text)
  end

  after_destroy do
    begin
      Sidekiq::ScheduledSet.new.scan(CreateTweetWorker.name).select do |job|
        if job.klass == CreateTweetWorker.name && job.args[0] == id
          job.delete
          break
        end
      end
    rescue => e
      logger.warn "after_destroy: #{e.inspect} id=#{id}"
    end
  end

  scope :published, -> do
    where.not(published_at: nil)
  end

  scope :not_published, -> do
    where(published_at: nil)
  end

  def published?
    !published_at.nil?
  end

  def publish_time
    published? ? published_at : time
  end

  class TextValidator
    include Twitter::TwitterText::Validation

    def initialize(text)
      @text = text
    end

    def valid?
      parse_tweet(@text)[:valid]
    end
  end
end
