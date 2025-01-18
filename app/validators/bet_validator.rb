class BetValidator
  include ActiveModel::Validations

  attr_reader :params

  validates :game_id, presence: true, numericality: { only_integer: true }
  validates :bet_type, presence: true, inclusion: { in: %w[moneyline spread totals] }
  validates :pick, presence: true, inclusion: { in: %w[home away draw over under] }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :odds, presence: true, numericality: { greater_than: 1.0, less_than_or_equal_to: 5.0 }

  def initialize(params)
    @params = params
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end
end
