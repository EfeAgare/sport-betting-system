require 'rails_helper'

RSpec.describe ErrorsController, type: :request do
  describe 'GET #routing_error' do
    it 'returns a 404 status and appropriate error message for an undefined route' do
      # Simulate a request to an undefined path
      get '/api/v1'

      # Check that the response status is 404 (Not Found)
      expect(response.status).to eq(404)

      # Parse JSON response and check message and error fields
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Not Found')
      expect(json_response['message']).to eq('The requested resource could not be found. Please check the URL or contact support.')
    end
  end
end
