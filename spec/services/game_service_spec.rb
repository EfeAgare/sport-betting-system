require 'rails_helper'

RSpec.describe GameService, type: :service do
  let(:page) { 1 }
  let(:per_page) { 10 }
  let(:start_date) { 1.week.ago }
  let(:end_date) { Time.now }

  describe '.all' do
    context 'when no games are cached' do
      it 'fetches the games from the database and caches the result' do
        expect(Rails.cache).to receive(:fetch).with("game_data_page_#{page}_per_page_#{per_page}").and_call_original
        game_data = GameService.all(page: page, per_page: per_page)

        expect(game_data).to include("games")
        expect(game_data).to include("meta")
      end
    end
  end

  describe '.clear_all_game_cache' do
    it 'clears the cached game data' do
      # Assume there is a cache set
      Rails.cache.write("game_data_page_#{page}_per_page_#{per_page}", { some_key: "some_value" })

      expect {
        GameService.clear_all_game_cache
      }.to change { Rails.cache.read("game_data_page_#{page}_per_page_#{per_page}") }.from({ some_key: "some_value" }).to(nil)
    end
  end
end
