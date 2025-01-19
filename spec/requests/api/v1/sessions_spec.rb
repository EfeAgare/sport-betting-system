require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }
  let(:valid_params) { { user: { email: 'user@example.com', password: 'password123' } } }
  let(:invalid_params) { { user: { email: 'user@example.com', password: 'wrongpassword' } } }

  describe 'POST /api/sign_in' do
    context 'when valid credentials are provided' do
      it 'authenticates the user and returns a token' do
        post '/api/sign_in', params: valid_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['user']['email']).to eq('user@example.com')
        expect(json_response['token']).to be_present
      end
    end

    context 'when invalid credentials are provided' do
      it 'returns an unauthorized error' do
        post '/api/sign_in', params: invalid_params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'when rate-limited due to too many attempts' do
      it 'returns 429 Too Many Requests on the 6th attempt' do
        6.times { post '/api/sign_in', params: invalid_params }

        expect(response).to have_http_status(:too_many_requests)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Too many login attempts. Please try again later.')
        expect(response.headers['Retry-After']).to eq('240') # Retry after 240 seconds (4 minutes)
      end
    end
  end

  describe 'DELETE /api/sign_out' do
    before do
      Rails.cache.clear # To help clear cache caused by rate limit
    end

    context 'when a valid token is provided' do
      it 'logs out the user successfully' do
        post '/api/sign_in', params: valid_params
        token = JSON.parse(response.body)['token']

        delete '/api/sign_out', headers: { Authorization: "Bearer #{token}" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Logged out successfully')
      end
    end

    context 'when an invalid token is provided' do
      it 'returns an error' do
        delete '/api/sign_out', headers: { Authorization: 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']["message"]).to eq("Invalid or expired token")
        expect(json_response['error']["code"]).to eq("unauthorized")
      end
    end
  end
end
