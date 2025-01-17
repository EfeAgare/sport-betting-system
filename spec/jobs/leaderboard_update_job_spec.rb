require 'rails_helper'

RSpec.describe LeaderboardUpdateJob, type: :job do
  let(:bet) { create(:bet, amount: 10000) } # Assuming you have a Bet factory
  let(:leaderboard_service) { instance_double("LeaderboardService") }
  let(:leaderboard_data) { double("Leaderboard", as_json: [ { id: 1, username: "user1", total_bets: 5 } ]) }

  before do
    allow(LeaderboardService).to receive(:calculate).and_return(leaderboard_data)
    allow($redis).to receive(:publish)
  end

  describe "#perform" do
    it "calculates the leaderboard and publishes updates to Redis" do
      expect(LeaderboardService).to receive(:calculate).once
      expect($redis).to receive(:publish).with("leaderboard_updates", leaderboard_data.as_json(only: [ :id, :username, :total_bets ]).to_json)

      LeaderboardUpdateJob.perform_now(bet)
    end
  end
end
