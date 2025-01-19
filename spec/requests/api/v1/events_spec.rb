require 'rails_helper'

RSpec.describe 'Api::V1::EventsController', type: :request do
  let!(:game) { create(:game) }
  let!(:event) { create(:event, game: game) }
  let(:valid_event_params) { { event: { event_type: 'goal', team: 'home', player: 'Player X', minute: 42 } } }
  let(:invalid_event_params) { { event: { team: '', player: '', minute: nil } } }

  describe 'POST /api/games/:game_id/events' do
    context 'with valid parameters' do
      it 'creates a new event' do
        post "/api/games/#{game.id}/events", params: valid_event_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['event_type']).to eq('goal')
        expect(json_response['team']).to eq('home')
        expect(json_response['player']).to eq('Player X')
        expect(json_response['minute']).to eq(42)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error and does not create an event' do
        post "/api/games/#{game.id}/events", params: invalid_event_params


        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include("Event type can't be blank")
      end
    end
  end

  describe 'PATCH /api/events/:id' do
    let(:valid_event_params) { { event: { event_type: 'goal', team: 'away', player: 'Player X', minute: 42 } } }
    context 'with valid parameters' do
      it 'updates the event successfully' do
        patch "/api/events/#{event.id}", params: valid_event_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['event_type']).to eq('goal')
        expect(json_response['team']).to eq('away')
        expect(json_response['player']).to eq('Player X')
        expect(json_response['minute']).to eq(42)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error and does not update the event' do
        patch "/api/events/#{event.id}", params: invalid_event_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include("Team can't be blank")
        expect(json_response['error']['code']).to include("unprocessable_entity")
      end
    end
  end
end
