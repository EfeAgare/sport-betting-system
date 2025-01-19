require 'rails_helper'

RSpec.describe Bet, type: :model do
  let(:user) { create(:user, balance: 100.0) } # Assuming you have a User factory
  let(:game) { create(:game) } # Assuming you have a Game factory

  describe "validations" do
    it "is valid with valid attributes" do
      bet = Bet.new(user: user, game: game, amount: 50.0, bet_type: "winner", pick: "home")
      expect(bet).to be_valid
    end

    it "is not valid without a user" do
      bet = Bet.new(game: game, amount: 50.0, bet_type: "winner", pick: "home")
      expect(bet).to_not be_valid
    end

    it "is not valid without a game" do
      bet = Bet.new(user: user, amount: 50.0, bet_type: "winner", pick: "home")
      expect(bet).to_not be_valid
    end

    it "is not valid with a negative amount" do
      bet = Bet.new(user: user, game: game, amount: -10.0, bet_type: "winner", pick: "home")
      expect(bet).to_not be_valid
    end

    it "is not valid if the user has insufficient balance" do
      user.update(balance: 10.0)
      bet = Bet.new(user: user, game: game, amount: 50.0, bet_type: "winner", pick: "home")
      expect(bet).to_not be_valid
    end
  end

  describe "callbacks" do
    it "calculates odds before saving" do
      bet = Bet.create(user: user, game: game, amount: 50.0, bet_type: "winner", pick: "home")
      expect(bet.odds).to be_present
    end
  end
end
