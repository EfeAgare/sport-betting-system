FactoryBot.define do
  factory :bet do
    association :user
    association :game
    bet_type { "winner" }
    pick { "home" }
    amount { 50.0 } # Set a default amount
    odds { 1.5 }    # Set a default odds value
  end
end
