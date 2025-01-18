module ApiRoutesConcern
  def self.routes(context)
    context.instance_exec do
      # Authentication routes
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"

      # User-related routes
      resources :users, only: [] do
        collection do
          put "update"
        end
        resources :bets, only: [ :index ]
      end

      # Game routes
      resources :games, only: [ :index, :show, :create, :update ] do
        resources :events, only: [ :create ]
      end

      # Event routes
      resources :events, only: [ :update ]

      # Bet creation
      resources :bets, only: [ :create ]
    end
  end
end
