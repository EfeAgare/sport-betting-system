require 'rails_helper'

RSpec.describe JwtBlacklist, type: :model do
  # Test presence validation
  it 'is invalid without a jti' do
    jwt_blacklist = JwtBlacklist.new(jti: nil)
    expect(jwt_blacklist).not_to be_valid
    expect(jwt_blacklist.errors[:jti]).to include("can't be blank")
  end

  # Test uniqueness validation
  it 'is invalid with a duplicate jti' do
    JwtBlacklist.create!(jti: 'unique-jti')
    duplicate_jwt_blacklist = JwtBlacklist.new(jti: 'unique-jti')
    expect(duplicate_jwt_blacklist).not_to be_valid
    expect(duplicate_jwt_blacklist.errors[:jti]).to include('has already been taken')
  end

  # Test valid jti
  it 'is valid with a unique jti' do
    jwt_blacklist = JwtBlacklist.new(jti: 'unique-jti')
    expect(jwt_blacklist).to be_valid
  end
end
