require 'swagger_helper'

RSpec.describe 'Api::V1::EventsController', type: :request do
  path '/api/games/{game_id}/events' do
    post 'Create an event for a game' do
      tags 'Events'
      consumes 'application/json'
      produces 'application/json'

      # Add the Api-Version header as a required parameter
      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version to use'

      parameter name: :game_id, in: :path, type: :integer, description: 'Game ID', required: true
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          event: {
            type: :object,
            properties: {
              event_type: { type: :string, example: 'goal' },
              team: { type: :string, example: 'home' },
              player: { type: :string, example: 'Player X' },
              minute: { type: :integer, example: 42 }
            },
            required: %w[event_type team player minute]
          }
        }
      }

      response '201', 'Event created successfully' do
        let(:game_id) { create(:game).id }
        let(:event) { { event: { event_type: 'goal', team: 'home', player: 'Player X', minute: 42 } } }
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:game_id) { create(:game).id }
        let(:event) { { event: { team: '', player: '', minute: nil } } }
        run_test!
      end
    end
  end

  path '/api/events/{id}' do
    patch 'Update an event' do
      tags 'Events'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: 'Event ID', required: true
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          event: {
            type: :object,
            properties: {
              event_type: { type: :string, example: 'goal' },
              team: { type: :string, example: 'away' },
              player: { type: :string, example: 'Player Y' },
              minute: { type: :integer, example: 60 }
            },
            required: %w[event_type team player minute]
          }
        }
      }

      response '200', 'Event updated successfully' do
        let(:id) { create(:event).id }
        let(:event) { { event: { event_type: 'goal', team: 'away', player: 'Player X', minute: 42 } } }
        run_test!
      end

      response '422', 'Invalid parameters' do
        let(:id) { create(:event).id }
        let(:event) { { event: { team: '', player: '', minute: nil } } }
        run_test!
      end
    end
  end
end
