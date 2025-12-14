Rails.application.routes.draw do
  root "pages#home"

  resources :items, only: %i[index show]

  namespace :api do
    resources :items, only: %i[index show] do
      resources :price_snapshots, only: %i[index]
    end
  end
end
