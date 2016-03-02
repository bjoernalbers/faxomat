Rails.application.routes.draw do
  get 'users/index'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users, only: [:index]

  root 'print_jobs#index'

  resources :reports, only: [:index, :show, :destroy, :update]

  resources :letters, only: [:create, :show]

  resources :attendances, only: [:new]

  resources :report_faxes, only: [:create]

  resource :template, except: [:destroy]

  #namespace :api, defaults: { format: :json } do
  #  resources :print_jobs, only: [:index]
  #  resources :reports, only: [:create, :show]
  #end
  namespace :api do
    resources :print_jobs, only: [:index], defaults: { format: :json }
    resources :reports, only: [:create, :show]
  end

  resources :faxes, only: :create

  resources :print_jobs, except: [:edit, :update] do
    get 'aborted', on: :collection
    get 'search', on: :collection
    get 'filter', on: :collection
  end
end
