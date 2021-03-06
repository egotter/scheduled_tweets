class ScheduledTweet < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  validates :text, presence: true
  validates :time, presence: true

  TIME_REGEXP = /\A\d{4}[\/-]\d{2}[\/-]\d{2} \d{2}:\d{2}\z/

  attr_accessor :time_str, :uploaded_files

  before_validation do
    unless RepeatTypeValidator::VALUES.include?(repeat_type)
      self.repeat_type = nil
    end

    if time_str.present? && time_str.match?(TIME_REGEXP)
      self.time = time_str.in_time_zone('Tokyo')
      self.time_str = nil
    end
  end

  MAX_TWEETS = 100

  validate on: :create do
    if time && !(time_validator = TimeValidator.new(time: time)).valid?
      errors.merge!(time_validator.errors)
    end

    if uploaded_files&.any?
      if uploaded_files.size > FileValidator::MAX_FILES
        errors.add(:base, I18n.t('activerecord.errors.messages.too_many_files', count: FileValidator::MAX_FILES))
      else
        uploaded_files.each do |uploaded_file|
          unless (file_validator = FileValidator.new(file: uploaded_file)).valid?
            errors.merge!(file_validator.errors)
            break
          end
        end
      end
    end

    if user.scheduled_tweets.will_be_published.size >= MAX_TWEETS
      errors.add(:base, I18n.t('activerecord.errors.messages.too_many_not_published_tweets', count: MAX_TWEETS))
    end

    if text && !TextValidator.new(text).valid?
      errors.add(:text, :text_too_long)
    end

    if text&.include?('*')
      errors.add(:text, :text_invalid)
    end
  end

  after_create do
    if uploaded_files&.any?
      images.attach(uploaded_files)
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

  scope :already_published, -> do
    where.not(published_at: nil)
  end

  scope :will_be_published, -> do
    where(published_at: nil).where('time >= ?', Time.zone.now)
  end

  scope :failed_to_publish, -> do
    where(published_at: nil).where('time < ?', Time.zone.now)
  end

  def published?
    !published_at.nil?
  end

  def publish!
    client = user.api_client

    if images.attached?
      files = []
      begin
        images.each do |image|
          image.open { |file| files << File.open(file.path) }
        end
        status = client.update_with_media(text, files)
      ensure
        files.each(&:close)
      end
      update(tweet_id: status.id, published_at: Time.zone.now)
    else
      status = client.update(text)
      update(tweet_id: status.id, published_at: Time.zone.now)
    end
  end

  def publish_time
    published? ? published_at : time
  end

  def repeat_specified?
    ScheduledTweet::RepeatTypeValidator::VALUES.include?(repeat_type)
  end

  def copy_for_repeat(uploaded_files)
    case repeat_type
    when ScheduledTweet::RepeatTypeValidator::VALUES[0]
      repeat_count = 6
    when ScheduledTweet::RepeatTypeValidator::VALUES[1]
      repeat_count = 13
    else
      raise "Invalid repeat_type value=#{repeat_type}"
    end

    repeat_count.times.map do |n|
      ScheduledTweet.new(
        user_id: user_id,
        text: text,
        time: time + (n + 1).days,
        uploaded_files: uploaded_files,
        repeat_type: repeat_type,
      )
    end
  end

  class TimeValidator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :time, :datetime

    validate :time_cannot_be_in_the_past,
             :time_cannot_be_in_the_distant_future

    def time_cannot_be_in_the_past
      if time.present? && time < 1.minute.since.in_time_zone('Tokyo')
        errors.add(:time, :cannot_be_in_the_past)
      end
    end

    def time_cannot_be_in_the_distant_future
      if time.present? && time > self.class.max_date
        errors.add(:time, :cannot_be_in_the_distant_future)
      end
    end

    class << self
      def max_date
        1.year.since.in_time_zone('Tokyo').to_date
      end
    end
  end

  class TextValidator
    include Twitter::TwitterText::Validation

    def initialize(text)
      @text = text
    end

    def valid?
      @text.present? && parse_tweet(@text)[:valid]
    end
  end

  class FileValidator
    include ActiveModel::Model

    attr_reader :size, :content_type, :file

    MAX_FILES = 4
    MAX_SIZE = 15000000
    CONTENT_TYPES = %w(image/jpeg image/png image/gif)

    validates :size, numericality: { less_than: MAX_SIZE, message: I18n.t('activemodel.errors.messages.file_size_too_big') }
    validates :content_type, inclusion: { in: CONTENT_TYPES, message: I18n.t('activemodel.errors.messages.invalid_content_type') }

    def initialize(file:)
      @size = file.size
      @content_type = file.content_type
      @file = file
    end
  end

  class RepeatTypeValidator
    VALUES = %w(repeat_for_7days repeat_for_14days)
  end
end
