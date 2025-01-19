require 'rails_helper'

RSpec.describe 'Api::V1::GamesController', type: :request do
  let!(:user) { create(:user) } # Assuming user is needed for authentication
  let(:valid_game_params) do
    {
      game: {
        home_team: 'Team A',
        away_team: 'Team B',
        home_score: 1,
        away_score: 2,
        status: 'finished',
        events_attributes: [
          { event_type: 'goal', team: 'Team A', player: 'Player 1', minute: 10 },
          { event_type: 'goal', team: 'Team B', player: 'Player 2', minute: 20 }
        ]
      }
    }
  end
  let(:invalid_game_params) do
    {
      game: {
        home_team: '',
        away_team: '',
        home_score: nil,
        away_score: nil,
        status: ''
      }
    }
  end

  describe 'POST /api/games' do
    context 'with valid parameters' do
      it 'creates a new game' do
        post '/api/games', params: valid_game_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['home_team']).to eq(valid_game_params[:game][:home_team])
        expect(json_response['away_team']).to eq(valid_game_params[:game][:away_team])
        expect(json_response['home_score']).to eq(valid_game_params[:game][:home_score])
        expect(json_response['away_score']).to eq(valid_game_params[:game][:away_score])
        expect(json_response['status']).to eq(valid_game_params[:game][:status])
        expect(json_response['events'].size).to eq(2)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error when required fields are missing' do
        post '/api/games', params: invalid_game_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include("Home team can't be blank")
        expect(json_response['error']['message']).to include("Away team can't be blank")
      end
    end
  end

  describe 'GET /api/games' do
    before do
      Rails.cache.clear # To help clear cache caused by rate limit

      create_list(:game, 10)
    end

    it 'retrieves all games' do
      get '/api/games'

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['games'].size).to eq(10)
      expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count', 'prev_page', 'next_page')
    end

    it 'retrieves games filtered by date range' do
      start_date = Date.today - 7
      end_date = Date.today
      get '/api/games', params: { start_date: start_date, end_date: end_date }, headers: { 'Authorization' => "Bearer #{@token}" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      # You can add more specific date assertions here
    end
  end

  describe 'GET /api/games/:id' do
    let!(:game) { create(:game, home_team: 'Team A', away_team: 'Team B', home_score: 1, away_score: 2, status: 'finished') }

    it 'retrieves a single game with its events and odds' do
      get "/api/games/#{game.id}"

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['game']['home_team']).to eq('Team A')
      expect(json_response['game']['away_team']).to eq('Team B')
      expect(json_response['game']['home_score']).to eq(1)
      expect(json_response['game']['away_score']).to eq(2)
      expect(json_response['odds']).to be_present # Assuming odds calculation is in the response
    end
  end
end
