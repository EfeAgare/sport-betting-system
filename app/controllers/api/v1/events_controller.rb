class Api::V1::EventsController < ApplicationController
  before_action :set_game, only: [ :create ]
  before_action :set_event, only: [ :update ]

  def create
    @event = @game.events.build(event_params)

    if @event.save
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      render json: @event, status: :ok
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:event_type, :team, :player, :minute)
  end
end
