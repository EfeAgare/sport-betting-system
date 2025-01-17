require 'swagger_helper'

RSpec.describe 'Events API', type: :request do
  path '/api/v1/games/{game_id}/events' do
    post 'Create a new Event' do
      tags 'Events'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token for authentication'
      parameter name: :game_id, in: :path, type: :integer, required: true, description: 'ID of the game'
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          event: {
            type: :object,
            properties: {
              event_type: { type: :string, example: 'goal', description: 'Type of the event' },
              team: { type: :string, example: 'home', description: 'Team associated with the event (home/away)' },
              player: { type: :string, example: 'Player 1', description: 'Player associated with the event' },
              minute: { type: :integer, example: 10, description: 'Minute when the event occurred' }
            },
            required: %w[event_type team player minute]
          }
        }
      }

      response '201', 'Event created successfully' do
        let(:Authorization) { "Bearer valid_token" }
        let(:game_id) { 1 }
        let(:event) do
          {
            event: {
              event_type: 'goal',
              team: 'home',
              player: 'Player 1',
              minute: 10
            }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['event_type']).to eq('goal')
          expect(json_response['team']).to eq('home')
          expect(json_response['player']).to eq('Player 1')
          expect(json_response['minute']).to eq(10)
        end
      end

      response '422', 'Invalid event parameters' do
        let(:Authorization) { "Bearer valid_token" }
        let(:game_id) { 1 }
        let(:event) do
          {
            event: {
              event_type: '',
              team: '',
              player: '',
              minute: nil
            }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['event_type']).to include("can't be blank")
          expect(json_response['team']).to include("can't be blank")
          expect(json_response['player']).to include("can't be blank")
          expect(json_response['minute']).to include("can't be blank")
        end
      end
    end
  end

  path '/api/v1/events/{id}' do
    patch 'Update an Event' do
      tags 'Events'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token for authentication'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'ID of the event'
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          event: {
            type: :object,
            properties: {
              minute: { type: :integer, example: 15, description: 'Updated minute for the event' }
            },
            required: [ 'minute' ]
          }
        }
      }

      response '200', 'Event updated successfully' do
        let(:Authorization) { "Bearer valid_token" }
        let(:id) { 1 }
        let(:event) do
          {
            event: { minute: 15 }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['minute']).to eq(15)
        end
      end

      response '422', 'Invalid event parameters' do
        let(:Authorization) { "Bearer valid_token" }
        let(:id) { 1 }
        let(:event) do
          {
            event: { minute: nil }
          }
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['minute']).to include("can't be blank")
        end
      end
    end
  end
end
