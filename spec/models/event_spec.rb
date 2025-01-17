require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:game) { create(:game) } # Assuming you have a Game factory

  describe "validations" do
    it "is valid with valid attributes" do
      event = Event.new(game: game, event_type: "goal", team: "home", player: "Player 1", minute: 10)
      expect(event).to be_valid
    end

    it "is not valid without a game" do
      event = Event.new(event_type: "goal", team: "home", player: "Player 1", minute: 10)
      expect(event).to_not be_valid
    end

    it "is not valid without an event_type" do
      event = Event.new(game: game, team: "home", player: "Player 1", minute: 10)
      expect(event).to_not be_valid
    end

    it "is not valid without a team" do
      event = Event.new(game: game, event_type: "goal", player: "Player 1", minute: 10)
      expect(event).to_not be_valid
    end

    it " is not valid without a player" do
      event = Event.new(game: game, event_type: "goal", team: "home", minute: 10)
      expect(event).to_not be_valid
    end

    it "is not valid without a minute" do
      event = Event.new(game: game, event_type: "goal", team: "home", player: "Player 1")
      expect(event).to_not be_valid
    end

    it "is not valid with a negative minute" do
      event = Event.new(game: game, event_type: "goal", team: "home", player: "Player 1", minute: -1)
      expect(event).to_not be_valid
    end
  end
end
