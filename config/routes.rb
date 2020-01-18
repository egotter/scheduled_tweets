Rails.application.routes.draw do
  root 'scheduled_tweets#new'
  resources :scheduled_tweets
end
