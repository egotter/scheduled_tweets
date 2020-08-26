require 'rails_helper'

RSpec.describe ScheduledTweet, type: :model do
  let(:user) { User.create!(uid: 1, screen_name: 'sn') }

  context 'after_create_commit' do
    let(:time) { '2020-01-01 00:00'.in_time_zone('Tokyo') }
    let(:instance) { described_class.new(user_id: user.id, text: 'text', time: time) }
    it do
      expect(CreateTweetWorker).to receive(:perform_at).with(time.utc, any_args)
      instance.save!
    end
  end
end
