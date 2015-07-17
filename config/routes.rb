Rails.application.routes.draw do
  root 'faxes#index'

  namespace :api, defaults: { format: :json } do
    resources :faxes, only: [:index]
  end

  resources :faxes, except: [:edit, :update] do
    get 'aborted', on: :collection
    get 'search', on: :collection
    get 'filter', on: :collection
    patch 'deliver', on: :member
  end
end
