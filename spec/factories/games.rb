FactoryBot.define do
  factory :game do
    home_team { "Team A" }
    away_team { "Team B" }
    home_score { 0 }
    away_score { 0 }
    time_elapsed { 0 }
    status { "scheduled" }
    sequence(:game_id) { |n| "G#{n}" }
  end
end
