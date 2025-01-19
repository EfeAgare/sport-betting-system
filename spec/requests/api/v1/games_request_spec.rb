require 'swagger_helper'

RSpec.describe 'Games API', type: :request do
  path '/api/v1/games' do
    post 'Create a new Game' do
      tags 'Games'
      consumes 'application/json'
      produces 'application/json'

      # Add the Api-Version header as a required parameter
      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version to use'

      parameter name: :game, in: :body, schema: {
        type: :object,
        properties: {
          home_team: { type: :string },
          away_team: { type: :string },
          home_score: { type: :integer },
          away_score: { type: :integer },
          status: { type: :string },
          events_attributes: {
            type: :array,
            items: {
              type: :object,
              properties: {
                event_type: { type: :string },
                team: { type: :string },
                player: { type: :string },
                minute: { type: :integer }
              },
              required: [ 'event_type', 'team', 'player', 'minute' ]
            }
          }
        },
        required: [ 'home_team', 'away_team', 'home_score', 'away_score', 'status' ]
      }

      response '201', 'Game created successfully' do
        let(:game) do
          {
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
        end
        run_test! do
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['home_team']).to eq(game[:home_team])
          expect(json_response['away_team']).to eq(game[:away_team])
          expect(json_response['home_score']).to eq(game[:home_score])
          expect(json_response['away_score']).to eq(game[:away_score])
          expect(json_response['status']).to eq(game[:status])
          expect(json_response['events'].size).to eq(2)
        end
      end

      response '422', 'Invalid request' do
        let(:game) { { home_team: '', away_team: '', home_score: nil, away_score: nil, status: '' } }
        run_test! do
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to include("Home team can't be blank")
          expect(json_response['error']['message']).to include("Away team can't be blank")
        end
      end
    end
  end

  path '/api/v1/games' do
    get 'Retrieves a list of games' do
      tags 'Games'
      produces 'application/json'

      parameter name: :start_date, in: :query, type: :string, format: 'date', description: 'Start date for filtering games'
      parameter name: :end_date, in: :query, type: :string, format: 'date', description: 'End date for filtering games'
      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination'
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page'

      response '200', 'List of games retrieved successfully' do
        let!(:games) { create_list(:game, 10) }
        run_test! do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['games'].size).to eq(10)
          expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count', 'prev_page', 'next_page')
        end
      end
    end
  end

  path '/api/v1/games/{id}' do
    get 'Retrieves a single game' do
      tags 'Games'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'Game ID'

      response '200', 'Game retrieved successfully' do
        let!(:game) { create(:game, home_team: 'Team A', away_team: 'Team B', home_score: 1, away_score: 2, status: 'finished') }
        run_test! do
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
  end
end
