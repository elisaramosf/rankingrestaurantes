
Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#index"
    resources :categories, except: :show
    resources :restaurants, except: :show
  end

  namespace :api do
    namespace :v1 do
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      resources :restaurants, only: %i[index show] do
        resources :reviews, only: %i[index create]
      end

      resources :reviews, only: %i[update destroy]
      resources :favorites, only: %i[index create]
      delete "favorites/:restaurant_id", to: "favorites#destroy"

      get "profile", to: "profiles#show"
      resources :users, only: :create
    end
  end

  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end
