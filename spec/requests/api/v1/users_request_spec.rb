require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    get 'List users with pagination and filtering' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Api-Version', in: :header, type: :string, required: true, example: '1', description: 'API version'

      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Users per page', required: false
      parameter name: :start_date, in: :query, type: :string, format: :date, description: 'Filter by start date', required: false
      parameter name: :end_date, in: :query, type: :string, format: :date, description: 'Filter by end date', required: false

      response '200', 'Users retrieved successfully' do
        schema type: :object,
               properties: {
                 users: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       username: { type: :string },
                       balance: { type: :number },
                       created_at: { type: :string, format: :date_time }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     total_count: { type: :integer },
                     total_pages: { type: :integer },
                     current_page: { type: :integer },
                     prev_page: { type: :integer, nullable: true },
                     next_page: { type: :integer, nullable: true }
                   }
                 }
               }

        let(:page) { 1 }
        let(:per_page) { 10 }
        run_test!
      end

      response '422', 'Invalid parameters' do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     message: { type: :string },
                     code: { type: :string }
                   }
                 }
               }

        let(:page) { -1 }
        let(:per_page) { 100 }
        run_test!
      end
    end
  end

  path '/api/users/update' do
    patch 'Update user details' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :Authorization, in: :header, type: :string, required: true, description: 'Bearer token'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string },
              balance: { type: :number }
            },
            required: %w[username balance]
          }
        }
      }

      response '200', 'User updated successfully' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 username: { type: :string },
                 balance: { type: :number }
               }

        let(:Authorization) { "Bearer #{::GenerateToken.new.call(create(:user))}" }
        let(:user) { { user: { username: 'new_username', balance: 500.0 } } }
        run_test!
      end

      response '422', 'Validation error' do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     message: { type: :string }
                   }
                 }
               }

        let(:Authorization) { "Bearer #{::GenerateToken.new.call(create(:user))}" }
        let(:user) { { user: { username: '', balance: '' } } }
        run_test!
      end

      response '429', 'Rate-limited' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:Authorization) { "Bearer #{::GenerateToken.new.call(create(:user))}" }
        before { 3.times { patch '/api/users/update', params: { user: { username: 'test', balance: 100 } }, headers: { Authorization: "Bearer #{::GenerateToken.new.call(create(:user))}" } } }
        let(:user) { { user: { username: 'test', balance: 100 } } }
        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     message: { type: :string }
                   }
                 }
               }

        let(:Authorization) { nil }
        let(:user) { { user: { username: 'new_username', balance: 500.0 } } }
        run_test!
      end
    end
  end
end
