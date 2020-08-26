require 'rails_helper'

RSpec.describe ScheduledTweetTime, type: :model do
  context 'date validation' do
    let(:instance) { described_class.new(date: date, time: '00:00') }

    [
        nil,
        '',
        'hello',
        '20200101'
    ].each do |date_value|
      context "date is #{date_value.inspect}" do
        let(:date) { date_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:date)).to be_truthy
        end
      end
    end

    [
        1.week.since.in_time_zone('Tokyo').strftime('%Y/%m/%d'),
        1.week.since.in_time_zone('Tokyo').strftime('%Y-%m-%d'),
    ].each do |date_value|
      context "date is #{date_value.inspect}" do
        let(:date) { date_value }
        it { expect(instance.valid?).to be_truthy }
      end
    end
  end

  context 'time validation' do
    let(:date) { 1.week.since.in_time_zone('Tokyo').strftime('%Y/%m/%d') }
    let(:instance) { described_class.new(date: date, time: time) }

    [
        nil,
        '',
        'hello',
        '1200'
    ].each do |time_value|
      context "time is #{time_value.inspect}" do
        let(:time) { time_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:time)).to be_truthy
        end
      end
    end

    [
        '20:00',
    ].each do |time_value|
      context "time is #{time_value.inspect}" do
        let(:time) { time_value }
        it { expect(instance.valid?).to be_truthy }
      end
    end
  end

  describe '#datetime_cannot_be_in_the_past' do
    let(:instance) { described_class.new }
    before do
      allow(instance).to receive(:datetime).and_return(30.seconds.since.in_time_zone('Tokyo'))
      instance.datetime_cannot_be_in_the_past
    end
    it do
      expect(instance.valid?).to be_falsey
      expect(instance.errors.has_key?(:datetime)).to be_truthy
    end
  end

  describe '#datetime_cannot_be_in_the_distant_future' do
    let(:instance) { described_class.new }
    before do
      allow(instance).to receive(:datetime).and_return(100.years.since.in_time_zone('Tokyo'))
      instance.datetime_cannot_be_in_the_distant_future
    end
    it do
      expect(instance.valid?).to be_falsey
      expect(instance.errors.has_key?(:datetime)).to be_truthy
    end
  end

  describe '#datetime' do
    let(:date) { 1.hour.since.in_time_zone('Tokyo').strftime('%Y/%m/%d') }
    let(:time) { 1.hour.since.in_time_zone('Tokyo').strftime('%H:%M') }
    let(:instance) { described_class.new(date: date, time: time) }
    subject { instance.datetime }
    it { expect(subject.strftime('%Y/%m/%d')).to eq(date) }
    it { expect(subject.strftime('%H:%M')).to eq(time) }
  end

  describe '#max_date' do
    subject { described_class.max_date }
    it do
      expect(subject).to be > 364.days.since.in_time_zone('Tokyo')
      expect(subject).to be < 366.days.since.in_time_zone('Tokyo')
    end
  end
end
