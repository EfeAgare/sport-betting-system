require 'swagger_helper'

RSpec.describe 'Events API', type: :request do
  path '/api/v1/games/{game_id}/events' do
    post 'Creates an event' do
      tags 'Events'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :game_id, in: :path, required: true, type: :integer
      parameter name: :event, in: :body, required: true, schema: {
        type: :object,
        properties: {
          event_type: { type: :string },
          team: { type: :string },
          player: { type: :string },
          minute: { type: :integer }
        },
        required: [ 'event_type', 'team', 'player', 'minute' ]
      }

      response '201', 'event created' do
        let(:game) { create(:game) }
        let(:valid_attributes) do
          {
            event: {
              event_type: "goal",
              team: "home",
              player: "Player 1",
              minute: 10
            }
          }
        end

        before do
          post "/api/v1/games/#{game.id}/events", params: valid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        end

        run_test! do |response|
          expect(response.status).to eq(201)
          expect(JSON.parse(response.body)['event_type']).to eq("goal")
          expect(JSON.parse(response.body)['team']).to eq("home")
          expect(JSON.parse(response.body)['player']).to eq("Player 1")
          expect(JSON.parse(response.body)['minute']).to eq(10)
        end
      end

      response '422', 'invalid request' do
        let(:invalid_attributes) do
          {
            event: {
              event_type: "",
              team: "",
              player: "",
              minute: nil
            }
          }
        end

        before do
          post "/api/v1/games/#{game.id}/events", params: invalid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        end

        run_test! do |response|
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)['event_type']).to include("can't be blank")
          expect(JSON.parse(response.body)['team']).to include("can't be blank")
          expect(JSON.parse(response.body)['player']).to include("can't be blank")
          expect(JSON.parse(response.body)['minute']).to include("can't be blank")
        end
      end
    end
  end

  path '/api/v1/events/{id}' do
    patch 'Updates an event' do
      tags 'Events'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :id, in: :path, required: true, type: :integer
      parameter name: :event, in: :body, required: true, schema: {
        type: :object,
        properties: {
          minute: { type: :integer }
        },
        required: [ 'minute' ]
      }

      response '200', 'event updated' do
        let(:event) { create(:event, game: create(:game)) }

        before do
          patch "/api/v1/events/#{event.id}", params: { event: { minute: 15 } }, headers: { 'Authorization' => "Bearer #{@token}" }
        end

        run_test! do |response|
          expect(response.status).to eq(200)
          expect(JSON.parse(response.body)['minute']).to eq(15)
        end
      end

      response '422', 'invalid request' do
        let(:event) { create(:event, game: create(:game)) }

        before do
          patch "/api/v1/events/#{event.id}", params: { event: { minute: nil } }, headers: { 'Authorization' => "Bearer #{@token}" }
        end

        run_test! do |response|
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)['minute']).to include("can't be blank")
        end
      end
    end
  end
end
