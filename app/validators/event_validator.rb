class EventValidator
  include ActiveModel::Validations

  attr_reader :params

  validates :event_type, presence: true, inclusion: { in: %w[goal yellow_card red_card substitution injury] }
  validates :team, presence: true, inclusion: { in: %w[home away] }
  validates :player, presence: true, length: { minimum: 2, maximum: 50 }
  validates :minute, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }

  def initialize(params)
    @params = params
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end
end
