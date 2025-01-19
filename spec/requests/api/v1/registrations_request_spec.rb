require 'swagger_helper'

RSpec.describe 'User Registrations', type: :request do
  path '/sign_up' do
    post 'Registers a new user' do
      tags 'User Registrations'
      consumes 'application/json'
      produces 'application/json'

      # Add the Api-Version header as a required parameter
      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version to use'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' },
              username: { type: :string, example: 'new_user' }
            },
            required: %w[email password username]
          }
        }
      }

      response '201', 'User created successfully' do
        let(:'Api-Version') { '1' }
        let(:user) { { user: { email: 'user@example.com', password: 'password123', username: 'new_user' } } }

        run_test!
      end

      response '422', 'Validation error' do
        let(:'Api-Version') { '1' }
        let(:user) { { user: { email: '', password: '', username: '' } } }

        run_test!
      end

      response '429', 'Too many requests' do
        let(:'Api-Version') { '1' }
        let(:user) { { user: { email: 'user@example.com', password: 'password123', username: 'new_user' } } }

        before do
          3.times { post '/api/sign_up', params: user, headers: { 'Api-Version' => '1' } }
        end

        run_test!
      end
    end
  end
end
