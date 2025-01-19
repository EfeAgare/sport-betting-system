require 'rails_helper'

RSpec.describe BettingOddsService do
  let(:game) { create(:game) }
  subject { described_class.new(game) }

  describe '#calculate' do
    context 'when there are no bets' do
      it 'returns default minimum odds' do
        odds = subject.calculate
        expect(odds).to eq({
          home: described_class::MIN_ODDS,
          away: described_class::MIN_ODDS,
          draw: described_class::MIN_ODDS
        })
      end
    end

    context 'with bets' do
      before do
        create(:bet, game: game, pick: 'home', amount: 100)
        create(:bet, game: game, pick: 'away', amount: 50)
        create(:bet, game: game, pick: 'draw', amount: 50)
      end

      it 'calculates odds within valid range' do
        odds = subject.calculate
        expect(odds[:home]).to be >= described_class::MIN_ODDS
        expect(odds[:home]).to be <= described_class::MAX_ODDS
        expect(odds[:away]).to be >= described_class::MIN_ODDS
        expect(odds[:away]).to be <= described_class::MAX_ODDS
        expect(odds[:draw]).to be >= described_class::MIN_ODDS
        expect(odds[:draw]).to be <= described_class::MAX_ODDS
      end
    end

    context 'with extreme betting scenarios' do
      it 'caps maximum odds' do
        create(:bet, game: game, pick: 'home', amount: 1)
        create(:bet, game: game, pick: 'away', amount: 1000)

        odds = subject.calculate
        expect(odds[:home]).to eq described_class::MAX_ODDS
      end

      it 'enforces minimum odds' do
        create(:bet, game: game, pick: 'home', amount: 100)
        create(:bet, game: game, pick: 'away', amount: 10000)

        odds = subject.calculate
        expect(odds[:away]).to eq described_class::MIN_ODDS
      end
    end
  end
end
