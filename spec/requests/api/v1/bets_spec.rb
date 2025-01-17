require 'rails_helper'

RSpec.describe "Api::V1::Bets", type: :request do
  let(:user) { create(:user, password: 'password', balance: 10000.0) }
  let(:game) { create(:game) }

  before do
    post '/api/v1/sign_in', params: { user: { email: user.email, password: 'password' } }
    @token = JSON.parse(response.body)['token']
  end

  describe "POST /api/v1/bets" do
    let(:valid_attributes) { { bet: { game_id: game.id, bet_type: 'winner', pick: 'home', amount: 50.0 } } }
    let(:invalid_attributes) { { bet: { game_id: game.id, bet_type: nil, pick: 'home', amount: -10 } } }

    context "with valid parameters" do
      it "creates a new Bet" do
        expect {
          post '/api/v1/bets', params: valid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        }.to change(Bet, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['game_id']).to eq(game.id)
        expect(json_response['amount']).to eq('50.0')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Bet" do
        expect {
          post '/api/v1/bets', params: invalid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        }.to change(Bet, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response.split(",").join(" ")).to include("Amount exceeds your available balance")
      end
    end
  end
end
