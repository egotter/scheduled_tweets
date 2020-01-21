class ScheduledTweet < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  attr_accessor :specified_date, :specified_time

  DATE_REGEXP = /\A\d{4}[\/-]\d{2}[\/-]\d{2}\z/
  TIME_REGEXP = /\A\d{2}:\d{2}\z/

  before_validation do
    if valid_specified_date? && valid_specified_time?
      self.time = specified_datetime
    end
  end

  after_validation do
    if errors.any? && errors.has_key?(:time) && (errors.has_key?(:specified_date) || errors.has_key?(:specified_time))
      errors.delete(:time)
    end
  end

  validates :text, presence: true
  validates :time, presence: true

  validate do
    if user.scheduled_tweets.not_published.size > 30
      errors.add(:base, I18n.t('activerecord.errors.messages.too_many_not_published_tweets', count: 30))
    end

    if text.to_s.include?('*')
      errors.add(:text, :text_invalid)
    end

    unless valid_specified_date?
      errors.add(:specified_date, :required)
    end

    unless valid_specified_time?
      errors.add(:specified_time, :required)
    end

    if valid_specified_date? && valid_specified_time?
      if specified_datetime_in_the_past?
        errors.add(:specified_date, :cannot_be_in_the_past)
        errors.add(:specified_time, :cannot_be_in_the_past)
      elsif specified_datetime_in_the_distant_future?
        errors.add(:specified_date, :cannot_be_in_the_distant_future)
        errors.add(:specified_time, :cannot_be_in_the_distant_future)
      end
    end
  end

  scope :published, -> do
    where.not(published_at: nil)
  end

  scope :not_published, -> do
    where(published_at: nil)
  end

  def valid_specified_date?
    specified_date.to_s.match?(DATE_REGEXP)
  end

  def valid_specified_time?
    specified_time.to_s.match?(TIME_REGEXP)
  end

  def specified_datetime
    "#{specified_date} #{specified_time}".in_time_zone('Tokyo')
  end

  def specified_datetime_in_the_past?
    specified_datetime < 1.minute.since
  end

  def specified_datetime_in_the_distant_future?
    specified_datetime > 1.month.since
  end

  def published?
    !published_at.nil?
  end

  def publish_time
    published? ? published_at : time
  end
end
