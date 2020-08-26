require 'rails_helper'

RSpec.describe ScheduledTweet, type: :model do
  let(:user) { User.create!(uid: 1, screen_name: 'sn') }

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
        described_class.create!(user_id: user.id, text: 'text', time: Time.zone.now)
      end
    end

    it do
      instance.valid?
      expect(instance.errors.has_key?(:base)).to be_truthy
    end
  end

  context 'after_create_commit' do
    let(:time) { '2020-01-01 00:00'.in_time_zone('Tokyo') }
    let(:instance) { described_class.new(user_id: user.id, text: 'text', time: time) }
    it do
      expect(CreateTweetWorker).to receive(:perform_at).with(time.utc, any_args)
      instance.save!
    end
  end
end
