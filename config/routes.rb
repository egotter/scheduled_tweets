Rails.application.routes.draw do
  root 'scheduled_tweets#index'
  resources :scheduled_tweets, only: [:index]

  namespace :api, {format: 'json'} do
    namespace :v1 do
      resources :scheduled_tweets, only: [:index, :create, :destroy]
    end
  end

  devise_for :users, skip: [:registrations, :sessions, :passwords],
             controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}
  devise_scope :user do
    match 'users/sign_out' => 'devise/sessions#destroy', as: 'destroy_user_session', via: [:get, :delete]
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.id == 1 } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
