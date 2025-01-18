class Event < ApplicationRecord
  # Represents an event that occurs within a game.

  belongs_to :game

  validates :event_type, :team, :player, :minute, presence: true
  validates :minute, numericality: { greater_than_or_equal_to: 0 }
end
