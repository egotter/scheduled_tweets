require 'rails_helper'

RSpec.describe CreateTweetWorker do
  let(:tweet) { ScheduledTweet.new(user_id: 1, text: 'text', time: 1.hour.since.in_time_zone('Tokyo')) }

  before do
    allow(ScheduledTweet).to receive(:find).with(tweet.id).and_return(tweet)
  end

  describe '#perform' do
    subject { described_class.new.perform(tweet.id) }

    context 'tweet has already been published' do
      before { allow(tweet).to receive(:published?).and_return(true) }
      it do
        expect(tweet).not_to receive(:publish!)
        subject
      end
    end

    context 'run over by 1 minute' do
      before { tweet.time = 1.minute.ago.in_time_zone('Tokyo') }
      it do
        expect(tweet).to receive(:publish!)
        subject
      end
    end

    context 'run over by 1 hour' do
      before { tweet.time = 1.hour.ago.in_time_zone('Tokyo') }
      it do
        expect(tweet).not_to receive(:publish!)
        subject
      end
    end
  end
end
