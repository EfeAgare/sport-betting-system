require 'rails_helper'

RSpec.describe 'Api::V1::UsersController', type: :request do
  let!(:users) { create_list(:user, 30) }
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{::GenerateToken.new.call(user)}" } }

  describe 'GET /api/v1/users' do
    it 'returns paginated users' do
      get '/api/v1/users', params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(10)
    end

    it 'returns the default number of users per page when per_page is not specified' do
      get '/api/v1/users', params: { page: 1 }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(25)
    end

    it 'allows unauthenticated access' do
      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT /api/v1/users/update' do
    let(:update_params) { { user: { username: 'UpdatedName', balance: '1000.5' } } }

    context 'when authenticated' do
      it 'updates the user successfully' do
        put '/api/v1/users/update', params: update_params, headers: headers

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['username']).to eq('UpdatedName')
        expect(body['balance']).to eq(update_params[:user][:balance])
      end
    end

    context 'when unauthenticated' do
      it 'returns unauthorized status' do
        put '/api/v1/users/update', params: update_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
