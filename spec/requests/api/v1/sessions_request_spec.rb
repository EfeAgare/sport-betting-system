require 'swagger_helper'

RSpec.describe 'User Sessions API', type: :request do
  path '/api/sign_in' do
    post 'Authenticates a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: %w[email password]
          }
        }
      }

      response '201', 'User authenticated successfully' do
        let(:'Api-Version') { '1' }
        let(:user) { { user: { email: 'user@example.com', password: 'password123' } } }

        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:'Api-Version') { '1' }
        let(:user) { { user: { email: 'user@example.com', password: 'wrongpassword' } } }

        run_test!
      end

      response '429', 'Too many requests' do
        let(:'Api-Version') { '1' }
        let(:user) { { user: { email: 'user@example.com', password: 'wrongpassword' } } }

        before do
          5.times { post '/api/sign_in', params: user, headers: { 'Api-Version' => '1' } }
        end

        run_test!
      end
    end
  end

  path '/api/sign_out' do
    delete 'Logs out a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: 'Authorization', in: :header, type: :string, required: true, example: 'Bearer {token}', description: 'JWT Token for authentication'
      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version'

      response '200', 'User logged out successfully' do
        let(:'Authorization') { "Bearer #{::GenerateToken.new.call(create(:user))}" }
        let(:'Api-Version') { '1' }

        run_test!
      end

      response '401', 'Invalid token provided' do
        let(:'Authorization') { 'Bearer invalid.token.here' }
        let(:'Api-Version') { '1' }

        run_test!
      end
    end
  end
end
