require 'swagger_helper'

RSpec.describe 'Games API', type: :request do
  path '/api/v1/games' do
    post 'Create a new Game' do
      tags 'Games'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token for authentication'
      parameter name: :game, in: :body, schema: {
        type: :object,
        properties: {
          game: {
            type: :object,
            properties: {
              home_team: { type: :string, example: 'Team A', description: 'Home team name' },
              away_team: { type: :string, example: 'Team B', description: 'Away team name' },
              home_score: { type: :integer, example: 0, description: 'Home team score' },
              away_score: { type: :integer, example: 0, description: 'Away team score' },
              time_elapsed: { type: :integer, example: 0, description: 'Time elapsed in the game' },
              status: { type: :string, example: 'scheduled', description: 'Status of the game (e.g., scheduled, ongoing, completed)' },
              events_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    event_type: { type: :string, example: 'goal', description: 'Type of event (e.g., goal, foul)' },
                    team: { type: :string, example: 'home', description: 'Team associated with the event' },
                    player: { type: :string, example: 'Player 1', description: 'Player who made the event' },
                    minute: { type: :integer, example: 10, description: 'Minute in which the event occurred' }
                  },
                  required: [ 'event_type', 'team', 'player', 'minute' ]
                }
              }
            },
            required: [ 'home_team', 'away_team', 'status' ]
          }
        },
        required: [ 'game' ]
      }

      response '201', 'Game created successfully' do
        let(:Authorization) { "Bearer valid_token" }
        let(:game) do
          {
            game: {
              home_team: 'Team A',
              away_team: 'Team B',
              home_score: 0,
              away_score: 0,
              time_elapsed: 0,
              status: 'scheduled'
            }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['home_team']).to eq('Team A')
          expect(json_response['away_team']).to eq('Team B')
        end
      end

      response '201', 'Game created with events successfully' do
        let(:Authorization) { "Bearer valid_token" }
        let(:game) do
          {
            game: {
              home_team: 'Team A',
              away_team: 'Team B',
              home_score: 0,
              away_score: 0,
              time_elapsed: 0,
              status: 'scheduled',
              events_attributes: [
                { event_type: 'goal', team: 'home', player: 'Player 1', minute: 10 },
                { event_type: 'foul', team: 'away', player: 'Player 2', minute: 20 }
              ]
            }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['home_team']).to eq('Team A')
          expect(json_response['away_team']).to eq('Team B')
        end
      end

      response '422', 'Invalid game parameters' do
        let(:Authorization) { "Bearer valid_token" }
        let(:game) do
          {
            game: {
              home_team: '',
              away_team: '',
              home_score: nil,
              away_score: nil,
              time_elapsed: nil,
              status: 'scheduled'
            }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['errors']).to include("Home team can't be blank", "Away team can't be blank")
        end
      end
    end
  end

  path '/api/v1/games' do
    get 'Get list of games' do
      tags 'Games'
      produces 'application/json'

      response '200', 'List of games' do
        let(:Authorization) { "Bearer valid_token" }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response).not_to be_empty
        end
      end
    end
  end

  path '/api/v1/games/{id}' do
    get 'Show a game by ID' do
      tags 'Games'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true, description: 'Game ID'
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token for authentication'

      response '200', 'Game details and odds' do
        let(:Authorization) { "Bearer valid_token" }
        let(:id) { 1 } # Assuming a game with ID 1 exists

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['game']['home_team']).to eq('Team A')
          expect(json_response['game']['away_team']).to eq('Team B')
          expect(json_response['odds']).to be_present
        end
      end
    end
  end
end
