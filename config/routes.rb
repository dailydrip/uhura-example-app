# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users

    root to: 'users#index'
  end
  devise_for :users
  post 'send_message' => 'home#send_message'
  get 'check_status' => 'home#status_ajax'
  root to: 'home#index'
end
