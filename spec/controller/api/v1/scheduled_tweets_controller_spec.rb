require 'rails_helper'

RSpec.describe Api::V1::ScheduledTweetsController, type: :controller do
  let(:user) { User.create!(uid: 1, screen_name: 'sn') }

  before do
    allow(controller).to receive(:authenticate_user!)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:tokyo_time) { 1.hour.since.in_time_zone('Tokyo') }
    let(:date) { tokyo_time.strftime('%Y/%m/%d') }
    let(:time) { tokyo_time.strftime('%H:%M') }
    it do
      post :create, params: {tweet_text: 'text', 'scheduled-date': date, 'scheduled-time': time}
      expect(response).to have_http_status(:ok)
    end
  end
end
