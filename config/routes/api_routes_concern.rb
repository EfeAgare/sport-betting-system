module ApiRoutesConcern
  def self.routes(context)
    context.instance_exec do
      # Authentication routes
      post "sign_up", to: "registrations#create"
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"
      get "users/:user_id/bets", to: "bets#history"

      # User-related routes
      resources :users, only: [ :index ] do
        collection do
          patch "update"
        end
      end

      # Game routes
      resources :games, only: [ :index, :show, :create, :update ] do
        resources :events, only: [ :create ]
      end

      # Event routes
      resources :events, only: [ :update ]

      # Bet routes
      resources :bets, only: [ :index, :create ]
    end
  end
end
