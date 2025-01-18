class Api::V1::EventsController < ApplicationController
  before_action :set_game, only: [ :create ]
  before_action :set_event, only: [ :update ]

  # Creates a new event for the specified game
  def create
    EventValidator.new(event_params).validate!

    @event = @game.events.build(event_params)
    # This raises ActiveRecord::RecordInvalid automatically if validation fails
    @event.save!
    render json: @event, status: :created
  end

  # Updates an existing event
  def update
    EventValidator.new(event_params).validate!
    # This raises ActiveRecord::RecordInvalid automatically if validation fails
    @event.update!(event_params)
    render json: @event, status: :ok
  end

  private

  # Finds the game associated with the event
  def set_game
    @game = Game.find(params[:game_id])
  end

  # Finds the event to be updated
  def set_event
    @event = Event.find(params[:id])
  end

  # Strong parameters for event creation and updates
  def event_params
    params.require(:event).permit(:event_type, :team, :player, :minute)
  end
end
