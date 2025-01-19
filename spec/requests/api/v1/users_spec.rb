require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:users) { create_list(:user, 30) }
  let(:user) { create(:user) }
  let(:auth_token) { ::GenerateToken.new.call(user) }
  let(:headers) { { Authorization: "Bearer #{auth_token}" } }
  let(:valid_update_params) { { user: { username: 'new_username', balance: 500.0 } } }
  let!(:recent_users) { create_list(:user, 10, created_at: 1.hour.ago) }
  let(:invalid_update_params) { { user: { username: '', balance: '' } } }

  describe 'GET /api/users' do
    context 'when fetching paginated users' do
      it 'returns a list of users with pagination metadata' do
        get '/api/users', params: { page: 1, per_page: 10 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['meta']['total_count']).to eq(40)
        expect(json_response['users'].size).to eq(10)
        expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count', 'prev_page', 'next_page')
      end

      it 'defaults to 25 users per page when per_page is not provided' do
        get '/api/users', params: { page: 1 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['meta']['total_count']).to eq(40)
        expect(json_response['users'].size).to eq(25)
      end
    end

    context 'when invalid pagination parameters are provided' do
      it 'returns an error response' do
        get '/api/users', params: { page: -1, per_page: 100 }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq("Page must be greater than 0")
        expect(json_response['error']['code']).to eq("unprocessable_entity")
      end
    end

    context 'when filtering by valid start_date and end_date' do
      it 'returns only users within the date range' do
        get '/api/users', params: { start_date: 1.day.ago.to_s, end_date: Time.current.to_s, page: 1 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['meta']['total_count']).to eq(10) # Only recent users
        expect(json_response['users'].size).to eq(10)
      end
    end

    context 'when no users match the date filter' do
      it 'returns an empty users list' do
        get '/api/users', params: { start_date: 10.days.ago.to_s, end_date: 8.days.ago.to_s, page: 1 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['meta']['total_count']).to eq(0)
        expect(json_response['users']).to be_empty
      end
    end

    context 'when invalid dates are provided' do
      it 'returns an error response' do
        get '/api/users', params: { start_date: 'invalid_date', end_date: Time.current.to_s }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Invalid date format')
      end
    end
  end

  describe 'PATCH /api/update' do
    context 'when a valid token and parameters are provided' do
      it 'updates the user successfully' do
        patch '/api/users/update', params: valid_update_params, headers: headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['username']).to eq('new_username')
        expect(json_response['balance'].to_d).to eq(500)
      end
    end

    context 'when invalid parameters are provided' do
      it 'returns a validation error' do
        patch '/api/users/update', params: invalid_update_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to include("Username can't be blank")
      end
    end

    context 'when rate-limited due to too many update attempts' do
      it 'returns 429 Too Many Requests on the 4th attempt' do
        4.times { patch '/api/users/update', params: invalid_update_params, headers: headers }

        expect(response).to have_http_status(:too_many_requests)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Too many signup attempts. Please try again later.')
        expect(response.headers['Retry-After']).to eq('240')
      end
    end

    context 'when no token is provided' do
      it 'returns an unauthorized error' do
        patch '/api/users/update', params: valid_update_params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq("Authorization token is missing")
      end
    end
  end
end
