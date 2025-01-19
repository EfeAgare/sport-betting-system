require 'rails_helper'

RSpec.describe UpdateLeaderboardJob, type: :job do
  let(:user) { create(:user) }           # Assuming you have a User factory
  let(:amount) { 100 }                   # Amount to be used for the bet
  let(:status) { 'win' }                 # Status of the bet
  let(:created_at) { Time.now }          # Time of the bet creation

  # Test that the job correctly calls the LeaderboardService
  it 'calls LeaderboardService.update_leaderboard' do
    expect(LeaderboardService).to receive(:update_leaderboard).with(user.id, amount, status, created_at)

    UpdateLeaderboardJob.perform_now(user.id, amount, status, created_at)
  end

  # Test that the job is enqueued properly
  it 'enqueues the job' do
    expect {
      UpdateLeaderboardJob.perform_later(user.id, amount, status, created_at)
    }.to have_enqueued_job(UpdateLeaderboardJob)
  end

  # Test that the job runs successfully
  it 'executes the job' do
    # You can also check if the leaderboard is updated correctly
    allow(LeaderboardService).to receive(:update_leaderboard)

    UpdateLeaderboardJob.perform_now(user.id, amount, status, created_at)

    expect(LeaderboardService).to have_received(:update_leaderboard).with(user.id, amount, status, created_at)
  end
end
