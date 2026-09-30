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
      resources :restaurants, only: %i[index show]
      get "profile", to: "profiles#show"
      resources :users, only: :create
    end
  end

  resource :session
  resources :passwords, param: :token

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end