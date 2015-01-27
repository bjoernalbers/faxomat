Rails.application.routes.draw do
  root 'faxes#index'

  resources :faxes, only: [:index, :new, :show, :create] do
    get 'undeliverable', on: :collection
    get 'search', on: :collection
    get 'harmsen', on: :collection
  end
end
