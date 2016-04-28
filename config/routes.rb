Rails.application.routes.draw do
  devise_for :users, skip: [:session,:password,:registration], :controllers => { :omniauth_callbacks => "callbacks" }

  root 'pages#index'

  mount SabisuRails::Engine => "/sabisu_rails"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api, defaults: { format: :json } do
    # TODO: enforce namespace / versioning: constraints: ApiConstraints.new(version: 1, default: true)
    namespace :v1 do
      resources :users, :only => [:show, :create, :update], param: :auth_token do
        resources :organization, :only => [:show, :create, :update, :destroy]
      end
      resources :donor, :only => [:show]
      # resources :driver, :only => [:show]
      namespace :donor do
        get 'donations' => 'donor_donations#index'
        post 'donations' => 'donor_donations#create'
      end
      namespace :driver do
        get 'status' => 'driver#check_status', as: :check_status
        get 'donations/all' => 'driver_donations#index', as: :donations_all
        get 'donations/pending' => 'driver_donations#pending', as: :donations_pending
        get 'donations/completed' => 'driver_donations#completed', as: :donations_completed
        get 'donations/accepted' => 'driver_donations#accepted', as: :donations_accepted
        get 'donations/cancelled' => 'driver_donations#cancelled', as: :donations_cancelled
        post 'donations/:donation_id/status' => 'driver_donations#status'
      end
      resources :donations, :only => [:show, :index, :update]
      resources :sessions, :only => [:create, :destroy]
    end
  end
end
