require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { create(:user, password: 'password') } # Ensure the user has a password

  describe "POST /api/v1/sign_in" do
    context "with valid credentials" do
      it "logs in the user and returns a token" do
        post '/api/v1/sign_in', params: { user: { email: user.email, password: 'password' } }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response).to have_key('token')
        expect(json_response['user']['email']).to eq(user.email)
      end
    end

    context "with invalid credentials" do
      it "returns an unauthorized response" do
        post '/api/v1/sign_in', params: { user: { email: user.email, password: 'wrongpassword' } }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Invalid email or password")
      end
    end
  end

  describe "DELETE /api/v1/sessions" do
    it "logs out the user" do
      post '/api/v1/sign_in', params: { user: { email: user.email, password: 'password' } }
      token = JSON.parse(response.body)['token']

      delete '/api/v1/sign_out', headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq("Logged out successfully")
    end
  end
end
