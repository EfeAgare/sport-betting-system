require 'rails_helper'

RSpec.describe 'Api::V1::BetsController', type: :request do
  let!(:user) { create(:user, balance: 100.0) } # Ensure the user has some balance
  let(:game) { create(:game) }
  let(:valid_bet_params) { { bet: { game_id: game.id, bet_type: 'moneyline', pick: 'away', amount: 50.0, odds: 2.0 } } }
  let(:invalid_bet_params) { { bet: { game_id: nil, bet_type: '', pick: '', amount: nil, odds: nil } } }
  let(:insufficient_balance_params) { { bet: { game_id: 1, bet_type: 'moneyline', pick: 'away', amount: 200.0, odds: 2.0 } } }

  before do
      Rails.cache.clear # To help clear cache caused by rate limit

    post '/api/sign_in', params: { user: { email: user.email, password: 'password' } }
    @token = JSON.parse(response.body)['token']
  end

  describe 'POST /api/bets' do
    context 'with valid parameters' do
      it 'creates a new bet' do
        post '/api/bets', params: valid_bet_params, headers: { 'Authorization' => "Bearer #{@token}" }
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['game_id']).to eq(game.id)
        expect(json_response['bet_type']).to eq(valid_bet_params[:bet][:bet_type])
        expect(json_response['pick']).to eq(valid_bet_params[:bet][:pick])
        expect(json_response['amount'].to_d).to eq(50.0)
        expect(json_response['odds'].to_d).to eq(2.0)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error and does not create a bet' do
        post '/api/bets', params: invalid_bet_params, headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include("Game can't be blank")
        expect(json_response['error']['message']).to include("Bet type can't be blank")
      end
    end

    context 'with insufficient balance' do
      it 'returns an error and does not create a bet' do
        post '/api/bets', params: insufficient_balance_params, headers: { 'Authorization' => "Bearer #{@token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include('Your balance is insufficient to place this bet')
      end
    end

    context 'with rate limit exceeded' do
      it 'returns a rate limit error' do
        # Send more than 5 requests in 1 minute
        6.times do
          post '/api/bets', params: valid_bet_params, headers: { 'Authorization' => "Bearer #{@token}" }
        end

        expect(response).to have_http_status(:too_many_requests)
        expect(response.headers['Retry-After']).to eq('60')
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Too many bet attempts. Please try again later.')
      end
    end
  end

  describe 'GET /api/bets' do
    before do
      create_list(:bet, 10, user: user)
    end

    it 'retrieves all bets for the user' do
      get '/api/bets', headers: { 'Authorization' => "Bearer #{@token}" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['bets'].size).to eq(10)
      expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count', 'prev_page', 'next_page')
    end
  end

  describe 'GET /api/users/:user_id/bets' do
    let(:other_user) { create(:user) }

    before do
      create_list(:bet, 10, user: user)
      create_list(:bet, 5, user: other_user)
    end

    it 'retrieves the betting history for a specific user' do
      get "/api/users/#{user.id}/bets", headers: { 'Authorization' => "Bearer #{@token}" }

      expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['bets'].size).to eq(10)
      expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count', 'prev_page', 'next_page')
    end

    it 'retrieves the betting history for another user' do
      get "/api/users/#{other_user.id}/bets", headers: { 'Authorization' => "Bearer #{@token}" }

      expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['bets'].size).to eq(5)
      expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count', 'prev_page', 'next_page')
    end
  end
end
