require 'rails_helper'

RSpec.describe 'User Registrations', type: :request do
  let(:valid_params) do
    { user: { email: 'user@example.com', password: 'password123', username: 'new_user' } }
  end

  let(:invalid_params) do
    { user: { email: '', password: '', username: '' } }
  end

  describe 'POST /api/sign_up' do
    context 'when the user registers successfully' do
      it 'creates a new user and returns a token' do
        post '/api/sign_up', params: valid_params

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['user']['email']).to eq('user@example.com')
        expect(json_response['user']['username']).to eq('new_user')
        expect(json_response['token']).to be_present
      end
    end

    context 'when the user already registers' do
      before do
        create(:user, email: 'user@example.com', password: 'password123', username: 'new_user')
      end
      it 'return validation error' do
        post '/api/sign_up', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
        expect(json_response['error']['message']).to include('Username has already been taken')
        expect(json_response['error']['code']).to eq('unprocessable_entity')
      end
    end

    context 'when rate-limited due to too many attempts' do
      it 'returns 429 Too Many Requests on the 4th attempt' do
        4.times { post '/api/sign_up', params: invalid_params }

        expect(response).to have_http_status(:too_many_requests)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Too many signup attempts. Please try again later.')
        expect(response.headers['Retry-After']).to eq('240') # 240 seconds = 4 minutes
      end
    end

    context 'when invalid parameters are provided' do
      before do
        Rails.cache.clear # To help clear cache caused by rate limit
      end

      it 'returns an error' do
        post '/api/sign_up', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include("Password can't be blank")
      end
    end
  end
end
