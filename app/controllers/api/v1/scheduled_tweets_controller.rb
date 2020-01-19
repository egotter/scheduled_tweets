class Api::V1::ScheduledTweetsController < ApiController
  def index
    render json: [{id: 1, text: 'text1'}, {id: 2, text: 'text2'}]
  end
end
