Rails.application.routes.draw do
  root "pages#home"
  get "/items", to: "pages#items"

  namespace :api do
    resources :items, only: %i[index show] do
      resources :price_snapshots, only: %i[index]
    end
  end
end
