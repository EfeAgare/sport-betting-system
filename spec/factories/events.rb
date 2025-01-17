
FactoryBot.define do
  factory :event do
    event_type { "goal" }
    team { "home" }
    player { "Player 1" }
    minute { 10 }
    game
  end
end
