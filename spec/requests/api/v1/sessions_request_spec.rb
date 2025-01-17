require 'swagger_helper'

RSpec.describe 'User Sessions API', type: :request do
  path '/api/v1/sign_in' do
    post 'Log in a user' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'test@example.com', description: 'Email address of the user' },
              password: { type: :string, example: 'password', description: 'Password for the user' }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response '201', 'user logged in successfully' do
        let(:user) { create(:user, password: 'password') }
        let(:credentials) { { user: { email: user.email, password: 'password' } } }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response).to have_key('token')
          expect(json_response['user']['email']).to eq(user.email)
        end
      end

      response '401', 'invalid credentials' do
        let(:user) { create(:user, password: 'password') }
        let(:credentials) { { user: { email: user.email, password: 'wrongpassword' } } }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Invalid email or password')
        end
      end
    end
  end

  path '/api/v1/sign_out' do
    delete 'Log out a user' do
      tags 'Sessions'
      produces 'application/json'

      parameter name: :Authorization, in: :header, required: true, schema: {
        type: :string,
        example: 'Bearer {token}',
        description: 'Authorization token for the logged-in user'
      }

      response '200', 'user logged out successfully' do
        let(:user) { create(:user, password: 'password') }
        let(:Authorization) do
          post '/api/v1/sign_in', params: { user: { email: user.email, password: 'password' } }
          "Bearer #{JSON.parse(response.body)['token']}"
        end

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Logged out successfully')
        end
      end
    end
  end
end
