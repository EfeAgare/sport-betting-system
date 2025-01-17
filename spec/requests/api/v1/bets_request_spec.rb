require 'swagger_helper'

RSpec.describe 'Bets API', type: :request do
  path '/api/v1/bets' do
    post 'Create a new bet' do
      tags 'Bets'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]

      parameter name: :bet, in: :body, schema: {
        type: :object,
        properties: {
          bet: {
            type: :object,
            properties: {
              game_id: { type: :integer },
              bet_type: { type: :string, enum: [ 'winner', 'spread', 'over_under' ], example: 'winner' },
              pick: { type: :string, example: 'home' },
              amount: { type: :number, example: 50.0 }
            },
            required: [ 'game_id', 'bet_type', 'pick', 'amount' ]
          }
        },
        required: [ 'bet' ]
      }

      response '201', 'Bet created successfully' do
        let(:Authorization) { "Bearer valid_token" }
        let(:bet) do
          {
            bet: {
              game_id: 1,
              bet_type: 'winner',
              pick: 'home',
              amount: 50.0
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['game_id']).to eq(1)
          expect(data['amount']).to eq('50.0')
        end
      end

      response '422', 'Invalid parameters' do
        let(:Authorization) { "Bearer valid_token" }
        let(:bet) do
          {
            bet: {
              game_id: 1,
              bet_type: nil,
              pick: 'home',
              amount: -10
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include("Amount exceeds your available balance")
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        let(:bet) do
          {
            bet: {
              game_id: 1,
              bet_type: 'winner',
              pick: 'home',
              amount: 50.0
            }
          }
        end

        run_test! do |response|
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
