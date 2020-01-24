Rails.application.routes.draw do
  root 'scheduled_tweets#index'
  resources :scheduled_tweets, only: [:index]

  namespace :api, {format: 'json'} do
    namespace :v1 do
      resources :scheduled_tweets, only: [:index, :create, :destroy]
    end
  end

  devise_for :users, skip: %i(sessions confirmations registrations passwords unlocks), controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

  devise_scope :user do
    get '/users/sign_out', to: 'devise/sessions#destroy'
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.id == 1 } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
