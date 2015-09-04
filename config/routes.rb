Rails.application.routes.draw do
  get 'users/index'

  #devise_for :users

  resources :users, only: [:index]

  root 'faxes#index'

  resources :reports, only: [:show] do
    put 'approve', on: :member
  end

  #namespace :api, defaults: { format: :json } do
  #  resources :faxes, only: [:index]
  #  resources :reports, only: [:create, :show]
  #end
  namespace :api do
    resources :faxes, only: [:index], defaults: { format: :json }
    resources :reports, only: [:create, :show]
  end

  resources :faxes, except: [:edit, :update] do
    get 'aborted', on: :collection
    get 'search', on: :collection
    get 'filter', on: :collection
    patch 'deliver', on: :member
  end
end
