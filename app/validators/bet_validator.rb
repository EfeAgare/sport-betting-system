class BetValidator
  include ActiveModel::Validations

  attr_accessor :game_id, :bet_type, :pick, :amount, :odds, :required_fields

  validates :game_id, presence: true, numericality: { only_integer: true }, if: -> { required?(:game_id) }
  validates :bet_type, presence: true, inclusion: { in: %w[moneyline spread totals],  message: "must be one of: moneyline, spread, or totals" },  if: -> { required?(:bet_type) }
  validates :pick, presence: true, inclusion: { in: %w[home away draw over under],  message: "must be one of: home away draw over under" }, if: -> { required?(:pick) }
  validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { required?(:amount) }
  validates :odds, presence: true, numericality: { greater_than: 1.0, less_than_or_equal_to: 5.0 }, if: -> { required?(:odds) }

  def initialize(params, required_fields: [])
    @params = params
    @game_id = params[:game_id]
    @bet_type = params[:bet_type]
    @pick = params[:pick]
    @amount = params[:amount]
    @odds = params[:odds]
    @required_fields = required_fields
  end

  def validate!
    raise ValidationError, errors.full_messages.join(", ") unless valid?
  end

  private

  def required?(field)
    required_fields.include?(field)
  end
end
