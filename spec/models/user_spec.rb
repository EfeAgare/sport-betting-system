require 'rails_helper'

RSpec.describe User, type: :model do
  # Test presence and uniqueness validations
  it 'is valid with valid attributes' do
    user = User.new(email: 'test@example.com', username: 'testuser', balance: 100, password: "1234567")
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
    user = User.new(username: 'testrttuser', balance: 100)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid without a username' do
    user = User.new(email: 'test@example.com', balance: 100)
    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("can't be blank")
  end

  it 'is invalid with a duplicate email' do
    User.create(email: 'test@example.com', username: 'testuser', balance: 100, password: "35gyrgjfhurhdujfbnjk")
    user = User.new(email: 'test@example.com', username: 'newuser', balance: 100)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("has already been taken")
  end

  it 'is invalid with a duplicate username' do
    User.create(email: 'test1@example.com', username: 'testuser', balance: 100, password: "35gyrrgjfhurhdujfbnjk")
    user = User.new(email: 'test2@example.com', username: 'testuser', balance: 100)
    expect(user).not_to be_valid
    expect(user.errors[:username]).to include("has already been taken")
  end

  it 'is invalid with a negative balance' do
    user = User.new(email: 'test@example.com', username: 'testuser', balance: -100)
    expect(user).not_to be_valid
    expect(user.errors[:balance]).to include('must be greater than or equal to 0')
  end

  it 'sets the default balance to 0 before create' do
    user = User.create(email: 'test@example.com', username: 'testuser')
    expect(user.balance).to eq(0)
  end
end
