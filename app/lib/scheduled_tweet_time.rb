class ScheduledTweetTime
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :string, default: ''
  attribute :time, :string, default: ''

  DATE_REGEXP = /\A\d{4}[\/-]\d{2}[\/-]\d{2}\z/
  TIME_REGEXP = /\A\d{2}:\d{2}\z/

  validates :date, presence: true, format: {with: DATE_REGEXP}
  validates :time, presence: true, format: {with: TIME_REGEXP}

  validate :datetime_cannot_be_in_the_past,
           :datetime_cannot_be_in_the_distant_future

  def datetime_cannot_be_in_the_past
    if datetime.present? && datetime < 1.minute.since.in_time_zone('Tokyo')
      errors.add(:datetime, :cannot_be_in_the_past)
    end
  end

  def datetime_cannot_be_in_the_distant_future
    if datetime.present? && datetime > self.class.max_date
      errors.add(:datetime, :cannot_be_in_the_distant_future)
    end
  end

  def datetime
    if date && time
      "#{date} #{time}".in_time_zone('Tokyo')
    end
  end

  class << self
    def max_date
      1.year.since.in_time_zone('Tokyo').to_date
    end
  end
end
