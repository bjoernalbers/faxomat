Rails.application.routes.draw do
  root 'faxes#index'

  resources :faxes, except: [:edit, :update] do
    get 'aborted', on: :collection
    get 'search', on: :collection
    get 'filter', on: :collection
    patch 'deliver', on: :member
  end
end
