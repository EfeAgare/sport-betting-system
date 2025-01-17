require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { create(:game) } # Assuming you have a Game factory

  describe "validations" do
    it "is valid with valid attributes" do
      expect(game).to be_valid
    end

    it "is not valid without a game_id" do
      game.game_id = nil
      expect(game).to_not be_valid
    end

    it "is not valid without home_team" do
      game.home_team = nil
      expect(game).to_not be_valid
    end

    it "is not valid without away_team" do
      game.away_team = nil
      expect(game).to_not be_valid
    end

    it "is not valid without home_score" do
      game.home_score = nil
      expect(game).to_not be_valid
    end

    it "is not valid without away_score" do
      game.away_score = nil
      expect(game).to_not be_valid
    end

    it "is not valid without time_elapsed" do
      game.time_elapsed = nil
      expect(game).to_not be_valid
    end

    it "is not valid with an invalid status" do
      game.status = "invalid_status"
      expect(game).to_not be_valid
    end
  end

  describe "callbacks" do
    it "broadcasts game updates after update" do
      expect($redis).to receive(:publish).with("game_updates", anything)
      game.update(home_score: 1)
    end

    it "sets default status on initialization" do
      new_game = Game.new
      expect(new_game.status).to eq("scheduled")
    end

    it "sets game_id on initialization" do
      new_game = Game.new
      expect(new_game.game_id).to start_with("G")
    end
  end
end
