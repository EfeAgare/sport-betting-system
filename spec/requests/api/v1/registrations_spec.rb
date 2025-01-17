require 'rails_helper'

RSpec.describe "Api::V1::Registrations", type: :request do
  describe "POST /api/v1/sign_up" do
    let(:valid_attributes) { { user: { email: 'test@example.com', password: 'password', username: 'testuser', balance: 100 } } }
    let(:invalid_attributes) { { user: { email: '', password: 'password', username: 'testuser', balance: 100 } } }

    context "with valid parameters" do
      it "creates a new User and returns a token" do
        expect {
          post '/api/v1/sign_up', params: valid_attributes
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response).to have_key('token')
        expect(json_response['user']['email']).to eq('test@example.com')
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post '/api/v1/sign_up', params: invalid_attributes
        }.to change(User, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to include("Email can't be blank")
      end
    end
  end
end
