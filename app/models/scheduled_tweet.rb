class ScheduledTweet < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  attr_accessor :specified_date, :specified_time

  before_validation do
    if self.specified_date.present? && self.specified_time.present?
      self.time = "#{self.specified_date} #{self.specified_time}".in_time_zone('Tokyo')
    end
  end

  after_validation do
    if self.errors.any? && self.errors.has_key?(:time)
      if self.specified_date.blank?
        self.errors.add(:specified_date, self.errors[:time][0])
      end

      if self.specified_time.blank?
        self.errors.add(:specified_time, self.errors[:time][0])
      end

      self.errors.delete(:time)
    end
  end

  validates :text, presence: true
  validates :time, presence: true

  scope :published, -> do
    where.not(published_at: nil)
  end

  scope :not_published, -> do
    where(published_at: nil)
  end
end
