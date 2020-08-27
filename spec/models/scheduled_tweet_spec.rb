require 'rails_helper'

RSpec.describe ScheduledTweet, type: :model do
  let(:user) { User.create!(uid: 1, screen_name: 'sn') }

  context 'before_validation' do
    let(:time) { '2020/01/01 01:00'.in_time_zone('Tokyo') }
    let(:instance) { described_class.new(user_id: user.id, text: 'text', time_str: time.strftime('%Y/%m/%d %H:%M')) }
    it do
      instance.valid?
      expect(instance.time).to eq(time.utc)
      expect(instance.time_str).to be_nil
    end
  end

  context 'time validation' do
    let(:instance) { described_class.new(user_id: user.id, text: 'text', time_str: time_str) }

    [
        nil,
        '',
        'aaa',
        1.hour.since.in_time_zone('Tokyo').strftime('%Y/%m/%d'),
        1.hour.since.in_time_zone('Tokyo').strftime('%H:%M'),
    ].each do |time_value|
      context "time_str is #{time_value.inspect}" do
        let(:time_str) { time_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:time)).to be_truthy
        end
      end
    end

    [
        1.hour.since.in_time_zone('Tokyo').strftime('%Y/%m/%d %H:%M'),
    ].each do |time_value|
      context "time_str is #{time_value.inspect}" do
        let(:time_str) { time_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:time)).to be_falsey
        end
      end
    end
  end

  context 'uploaded_files validation' do
    let(:instance) { described_class.new(user_id: user.id, text: 'text', uploaded_files: [uploaded_file]) }

    [
        ActionDispatch::Http::UploadedFile.new(filename: 'image_48x48.jpg', type: 'image/jpeg', tempfile: File.open(Rails.root.join('public', 'image_48x48.jpg'))),
    ].each do |file_value|
      context "uploaded_file is #{file_value.inspect}" do
        let(:uploaded_file) { file_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:size)).to be_falsey
          expect(instance.errors.has_key?(:content_type)).to be_falsey
        end
      end
    end
  end

  context 'text validation' do
    let(:instance) { described_class.new(user_id: user.id, text: text) }

    [
        nil,
        '',
        'aaa * bbb',
    ].each do |text_value|
      context "text is #{text_value.inspect}" do
        let(:text) { text_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:text)).to be_truthy
        end
      end
    end

    [
        'Hello everyone',
    ].each do |text_value|
      context "text is #{text_value.inspect}" do
        let(:text) { text_value }
        it do
          instance.valid?
          expect(instance.errors.has_key?(:text)).to be_falsey
        end
      end
    end
  end

  context 'max number of tweets validation' do
    let(:instance) { described_class.new(user_id: user.id, text: 'text') }

    before do
      100.times do
        described_class.create!(user_id: user.id, text: 'text', time: 1.hour.since.in_time_zone('Tokyo'))
      end
    end

    it do
      instance.valid?
      expect(instance.errors.has_key?(:base)).to be_truthy
    end
  end

  context 'after_create_commit' do
    it do
      travel_to '2020/01/01 01:00' do
        time = 1.hour.since.in_time_zone('Tokyo')
        instance = described_class.new(user_id: user.id, text: 'text', time: time)

        expect(CreateTweetWorker).to receive(:perform_at).with(time.utc, any_args)
        instance.save!
      end
    end
  end
end

RSpec.describe ScheduledTweet::TimeValidator, type: :model do
  describe '#time_cannot_be_in_the_past' do
    let(:instance) { described_class.new(time: 30.seconds.since.in_time_zone('Tokyo')) }
    subject { instance.time_cannot_be_in_the_past }
    it do
      subject
      expect(instance.errors.has_key?(:time)).to be_truthy
    end
  end

  describe '#time_cannot_be_in_the_distant_future' do
    let(:instance) { described_class.new(time: 100.years.since.in_time_zone('Tokyo')) }
    subject { instance.time_cannot_be_in_the_distant_future }
    it do
      subject
      expect(instance.errors.has_key?(:time)).to be_truthy
    end
  end

  describe '#max_date' do
    subject { described_class.max_date }
    it do
      expect(subject).to be > 364.days.since.in_time_zone('Tokyo')
      expect(subject).to be < 366.days.since.in_time_zone('Tokyo')
    end
  end
end

RSpec.describe ScheduledTweet::TextValidator, type: :model do
  describe '#valid?' do
    let(:instance) { described_class.new(text) }

    [
        nil,
        '',
    ].each do |text_value|
      context "text is #{text_value.inspect}" do
        let(:text) { text_value }
        it do
          expect(instance.valid?).to be_falsey
        end
      end
    end

    [
        'Hello',
    ].each do |text_value|
      context "text is #{text_value.inspect}" do
        let(:text) { text_value }
        it do
          expect(instance.valid?).to be_truthy
        end
      end
    end
  end
end
