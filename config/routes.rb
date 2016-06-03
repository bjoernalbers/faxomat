Rails.application.routes.draw do
  get 'users/index'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users, only: [:index]

  root 'documents#index'

  resources :reports, only: [:index, :show, :destroy, :update] do
    patch :verify, on: :member
    resources :printings, only: [:new, :create]
  end

  resources :documents, only: [:index, :show] do
    member do
      get :download
    end
  end
  resources :deliver_documents, only: :index
  resources :search_documents, only: :index

  resources :attendances, only: [:new]

  resources :report_faxes, only: [:create]

  resource :template, except: [:destroy]

  #namespace :api, defaults: { format: :json } do
  #  resources :print_jobs, only: [:index]
  #  resources :reports, only: [:create, :show]
  #end
  namespace :api do
    resources :print_jobs, only: [:index], defaults: { format: :json }
    resources :reports, only: [:create, :update, :show]
  end

  resources :faxes, only: :create

  resources :print_jobs, except: [:edit, :update] do
    get 'aborted', on: :collection
    get 'search', on: :collection
    get 'filter', on: :collection
  end
end
