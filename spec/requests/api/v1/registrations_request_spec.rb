require 'swagger_helper'

RSpec.describe 'User Registration API', type: :request do
  path '/api/v1/sign_up' do
    post 'Registers a new user' do
      tags 'Registrations'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'test@example.com', description: 'Email address of the user' },
              password: { type: :string, example: 'password', description: 'Password for the user' },
              username: { type: :string, example: 'testuser', description: 'Username for the user' },
              balance: { type: :number, example: 100, description: 'Initial balance for the user' }
            },
            required: [ 'email', 'password', 'username', 'balance' ]
          }
        }
      }

      response '201', 'user created successfully' do
        let(:user) { { user: { email: 'test@example.com', password: 'password', username: 'testuser', balance: 100 } } }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response).to have_key('token')
          expect(json_response['user']['email']).to eq('test@example.com')
        end
      end

      response '422', 'invalid parameters' do
        let(:user) { { user: { email: '', password: 'password', username: 'testuser', balance: 100 } } }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be false
          expect(json_response['errors']).to include("Email can't be blank")
        end
      end
    end
  end
end
