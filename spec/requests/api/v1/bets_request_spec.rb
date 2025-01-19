require 'swagger_helper'

RSpec.describe 'Bets API', type: :request do
  path '/api/v1/bets' do
    post 'Create a new bet' do
      tags 'Bets'
      consumes 'application/json'
      # Add the Api-Version header as a required parameter
      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version to use'

      parameter name: :bet, in: :body, schema: {
        type: :object,
        properties: {
          bet: {
            type: :object,
            required: [ 'game_id', 'bet_type', 'pick', 'amount', 'odds' ],
            properties: {
              game_id: { type: :integer, example: 1 },
              bet_type: { type: :string, example: 'moneyline' },
              pick: { type: :string, example: 'away' },
              amount: { type: :number, format: :float, example: 50.0 },
              odds: { type: :number, format: :float, example: 2.0 }
            }
          }
        },
        required: [ 'bet' ]
      }

      response '201', 'Bet created successfully' do
        let!(:game) { create(:game) }
        let!(:user) { create(:user, balance: 100.0) }
        let(:valid_bet_params) { { bet: { game_id: game.id, bet_type: 'moneyline', pick: 'away', amount: 50.0, odds: 2.0 } } }
        before do
          post '/api/v1/bets', params: valid_bet_params, headers: { 'Authorization' => "Bearer #{@token}" }
        end
        run_test! do
          expect(response.status).to eq(201)
          json_response = JSON.parse(response.body)
          expect(json_response['game_id']).to eq(game.id)
          expect(json_response['bet_type']).to eq(valid_bet_params[:bet][:bet_type])
          expect(json_response['pick']).to eq(valid_bet_params[:bet][:pick])
          expect(json_response['amount'].to_d).to eq(50.0)
          expect(json_response['odds'].to_d).to eq(2.0)
        end
      end

      response '422', 'Invalid parameters' do
        let(:invalid_bet_params) { { bet: { game_id: nil, bet_type: '', pick: '', amount: nil, odds: nil } } }
        before do
          post '/api/v1/bets', params: invalid_bet_params, headers: { 'Authorization' => "Bearer #{@token}" }
        end
        run_test! do
          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to include("Game can't be blank")
          expect(json_response['error']['message']).to include("Bet type can't be blank")
        end
      end

      response '423', 'Insufficient balance' do
        let(:insufficient_balance_params) { { bet: { game_id: 1, bet_type: 'moneyline', pick: 'away', amount: 200.0, odds: 2.0 } } }
        before do
          post '/api/v1/bets', params: insufficient_balance_params, headers: { 'Authorization' => "Bearer #{@token}" }
        end
        run_test! do
          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to include('Your balance is insufficient to place this bet')
        end
      end

      response '429', 'Rate limit exceeded' do
        before do
          # Send more than 5 requests in 1 minute
          6.times do
            post '/api/v1/bets', params: valid_bet_params, headers: { 'Authorization' => "Bearer #{@token}" }
          end
        end
        run_test! do
          expect(response).to have_http_status(:too_many_requests)
          expect(response.headers['Retry-After']).to eq('60')
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Too many bet attempts. Please try again later.')
        end
      end
    end
  end

  path '/api/v1/bets' do
    get 'Retrieve all bets' do
      tags 'Bets'
      consumes 'application/json'
      response '200', 'Successfully retrieved all bets' do
        let!(:user) { create(:user) }
        let!(:bet) { create(:bet, user: user) }
        before do
          get '/api/v1/bets', headers: { 'Authorization' => "Bearer #{@token}" }
        end
        run_test! do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['bets']).not_to be_empty
        end
      end
    end
  end
end
