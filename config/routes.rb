Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#index"
    resources :categories, except: :show
    resources :restaurants, except: :show
  end

  resource :session
  resources :passwords, param: :token

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end