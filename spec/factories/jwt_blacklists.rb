FactoryBot.define do
  factory :jwt_blacklist do
    jti { SecureRandom.uuid }
  end
end
