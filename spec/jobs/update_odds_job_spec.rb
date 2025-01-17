require 'rails_helper'

RSpec.describe UpdateOddsJob, type: :job do
  let(:game) { create(:game) } # Assuming you have a Game factory
  let(:new_odds) { { home: 1.5, away: 2.0 } } # Example odds
  let(:game_id) { game.id }

  before do
    allow(Game).to receive(:find).with(game_id).and_return(game)
    allow(game).to receive(:calculate_odds).and_return(new_odds)
    allow($redis).to receive(:publish)
  end

  describe "#perform" do
    it "finds the game, calculates new odds, and publishes updates to Redis" do
      expect(Game).to receive(:find).with(game_id).once
      expect(game).to receive(:calculate_odds).once
      expect($redis).to receive(:publish).with("odds_updates", { game_id: game.id, odds: new_odds }.to_json)

      UpdateOddsJob.perform_now(game_id)
    end
  end
end
