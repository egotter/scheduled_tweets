class ScheduledTweet < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :text, presence: true
  validates :time, presence: true

  validate on: :create do
    if user.scheduled_tweets.not_published.size > 30
      errors.add(:base, I18n.t('activerecord.errors.messages.too_many_not_published_tweets', count: 30))
    end

    if text.to_s.include?('*')
      errors.add(:text, :text_invalid)
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
end
