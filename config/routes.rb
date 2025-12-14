Rails.application.routes.draw do
  root "pages#home"
  get "/items", to: "pages#items"
end
