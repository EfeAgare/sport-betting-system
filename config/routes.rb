require_relative "./routes/api_routes_concern"

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app
  # boots with no exceptions,otherwise 500. Can be used
  # by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # API routes with versioning
  namespace :api, defaults: { format: :json } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      ApiRoutesConcern.routes(self) # Invoke the concern's routes method
    end

    # When you need to add v2, just include the concern
    # scope module: :v2, constraints: ApiConstraints.new(version: 2) do
    #   include ApiRoutesConcern
    # end
  end
end
