class Event < ApplicationRecord
  belongs_to :game

  validates :event_type, :team, :player, :minute, presence: true
  validates :minute, numericality: { greater_than_or_equal_to: 0 }
end
