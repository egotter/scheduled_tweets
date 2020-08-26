require 'rails_helper'

RSpec.describe ScheduledTweetsController, type: :controller do
  describe 'GET #index' do
    it do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
