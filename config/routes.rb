Rails.application.routes.draw do
  root 'scheduled_tweets#index'
  resources :scheduled_tweets

  namespace :api, {format: 'json'} do
    namespace :v1 do
      resources :scheduled_tweets, only: [:index]
    end
  end
end
