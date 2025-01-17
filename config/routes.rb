Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  #

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"
      resources :bets, only: [ :create ]
      resources :users, only: [] do
        resources :bets, only: [ :index ]
      end

      resources :games, only: [ :index, :show, :create, :update ] do
        resources :events, only: [ :create ]
      end

      resources :events, only: [ :update ]
      resources :users, only: [ :index ] do
        collection do
          put "update"
        end
      end
    end
  end
end
