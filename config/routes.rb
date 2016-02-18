Rails.application.routes.draw do
  get 'users/index'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users, only: [:index]

  root 'faxes#index'

  resources :reports, only: [:index, :show, :destroy, :update]

  resources :letters, only: [:create, :show]

  resources :attendances, only: [:new]

  resources :report_faxes, only: [:create]

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
  end
end
