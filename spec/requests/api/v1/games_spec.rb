require 'rails_helper'

RSpec.describe "Api::V1::Games", type: :request do
  let(:valid_with_event_attributes) do
    {
      game: {
        home_team: "Team A",
        away_team: "Team B",
        home_score: 0,
        away_score: 0,
        time_elapsed: 0,
        status: "scheduled",
        events_attributes: [
          { event_type: "goal", team: "home", player: "Player 1", minute: 10 },
          { event_type: "foul", team: "away", player: "Player 2", minute: 20 }
        ]
      }
    }
  end

  let(:valid_attributes) do
    {
      game: {
        home_team: "Team A",
        away_team: "Team B",
        home_score: 0,
        away_score: 0,
        time_elapsed: 0,
        status: "scheduled"
      }
    }
  end

  let(:invalid_attributes) do
    {
      game: {
        home_team: "",
        away_team: "",
        home_score: nil,
        away_score: nil,
        time_elapsed: nil,
        status: "scheduled"
      }
    }
  end

  let(:user) { create(:user, password: 'password', balance: 10000.0) }

  before do
    post '/api/v1/sign_in', params: { user: { email: user.email, password: 'password' } }
    @token = JSON.parse(response.body)['token']
  end

  describe "POST /api/v1/games" do
    context "with valid parameters" do
      it "creates a new Game" do
        expect {
          post '/api/v1/games', params: valid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        }.to change(Game, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['home_team']).to eq("Team A")
        expect(json_response['away_team']).to eq("Team B")
      end
    end

    context "with valid parameters with event" do
      it "creates a new Game" do
        expect {
          post '/api/v1/games', params: valid_with_event_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        }.to change(Game, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['home_team']).to eq("Team A")
        expect(json_response['away_team']).to eq("Team B")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Game" do
        expect {
          post '/api/v1/games', params: invalid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        }.to change(Game, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Home team can't be blank", "Away team can't be blank")
      end
    end
  end

  describe "GET /api/v1/games" do
    it "returns a list of games" do
      create(:game) # Assuming you have a game factory
      get '/api/v1/games'

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).not_to be_empty
    end
  end

  describe "GET /api/v1/games/:id" do
    let(:game) { create(:game) } # Create a game for the show action

    it "returns the game and its odds" do
      get "/api/v1/games/#{game.id}"

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['game']['home_team']).to eq(game.home_team)
      expect(json_response['game']['away_team']).to eq(game.away_team)
      expect(json_response['odds']).to be_present # Assuming calculate_odds returns something
    end
  end
end
