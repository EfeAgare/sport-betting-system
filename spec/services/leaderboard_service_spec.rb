require 'rails_helper'

RSpec.describe LeaderboardService, type: :service do
  let(:user) { create(:user) }
  let(:bet_amount) { 100 }
  let(:status) { 'win' }
  let(:created_at) { Time.now }

  describe '.update_leaderboard' do
    it 'updates the leaderboard with the correct bet amount and status' do
      expect($redis).to receive(:zscore).with(LeaderboardService::LEADERBOARD_KEY, user.id).and_return(0)
      expect($redis).to receive(:zadd).with(LeaderboardService::LEADERBOARD_KEY, bet_amount, user.id)
      expect($redis).to receive(:zincrby).with(LeaderboardService::WINS_KEY, 1, user.id)

      LeaderboardService.update_leaderboard(user.id, bet_amount, status, created_at)
    end
  end

  describe '.calculate' do
    it 'returns the leaderboard data for the given page and per_page' do
      # Assuming user 1 has made some bets
      $redis.zadd(LeaderboardService::LEADERBOARD_KEY, 100, user.id)
      $redis.zincrby(LeaderboardService::WINS_KEY, 1, user.id)
      $redis.zincrby(LeaderboardService::LOSSES_KEY, 1, user.id)

      result = LeaderboardService.calculate(page: 1, per_page: 10)

      expect(result).to be_an(Array)
      expect(result.first).to have_key(:id)
      expect(result.first).to have_key(:username)
      expect(result.first).to have_key(:total_bets)
      expect(result.first).to have_key(:wins)
      expect(result.first).to have_key(:losses)
    end
  end
end
