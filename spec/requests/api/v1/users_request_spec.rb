require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'List users with pagination' do
      tags 'Users'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number for pagination'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Number of users per page'

      response '200', 'paginated list of users' do
        let!(:users) { create_list(:user, 30) }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response.size).to eq(10)
        end
      end

      response '200', 'default number of users when per_page is not specified' do
        let!(:users) { create_list(:user, 30) }
        let(:page) { 1 }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response.size).to eq(25) # Assuming default pagination is 25 per page
        end
      end
    end
  end

  path '/api/v1/users/update' do
    put 'Update user details' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token for authentication'
      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string, example: 'UpdatedName', description: 'New username for the user' },
              balance: { type: :string, example: '1000.5', description: 'Updated balance for the user' }
            },
            required: [ 'username', 'balance' ]
          }
        }
      }

      response '200', 'user updated successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{::GenerateToken.new.call(user)}" }
        let(:user) { { user: { username: 'UpdatedName', balance: '1000.5' } } }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['username']).to eq('UpdatedName')
          expect(json_response['balance']).to eq('1000.5')
        end
      end

      response '401', 'unauthorized access' do
        let(:user) { { user: { username: 'UpdatedName', balance: '1000.5' } } }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
