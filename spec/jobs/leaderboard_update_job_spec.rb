require 'rails_helper'

RSpec.describe LeaderboardUpdateJob, type: :job do
  let(:start_date) { Date.today - 7.days }
  let(:end_date) { Date.today }
  let(:user_id) { 1 }
  let(:leaderboard_data) { [ { id: user_id, username: 'TestUser', total_bets: 100, wins: 5, losses: 3 } ] } # Make this an array

  before do
    allow(LeaderboardService).to receive(:calculate).and_return(leaderboard_data) # Mocking LeaderboardService calculation
    allow($redis).to receive(:publish) # Mocking Redis publish method
  end

  describe '#perform' do
    it 'calculates the leaderboard and publishes updates to Redis' do
      # Run the job
      LeaderboardUpdateJob.perform_now(start_date: start_date, end_date: end_date)

      # Check if LeaderboardService was called with the correct arguments
      expect(LeaderboardService).to have_received(:calculate).with(start_date: start_date, end_date: end_date)

      # Check if Redis publish method was called with the correct leaderboard data (as an array)
      expect($redis).to have_received(:publish).with('leaderboard_updates', leaderboard_data.to_json)
    end
  end
end
