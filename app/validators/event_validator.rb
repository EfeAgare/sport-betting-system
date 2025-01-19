class EventValidator
  include ActiveModel::Validations

  attr_accessor :team, :event_type, :minute, :player, :required_fields

  validates :event_type, presence: true, inclusion: { in: %w[goal yellow_card red_card substitution injury], message: "must be one of: goal yellow_card red_card substitution injury" }, if: -> { required?(:event_type) }
  validates :team, presence: true, inclusion: { in: %w[home away], message: "must be one of: home away" }, if: -> { required?(:team) }
  validates :player, presence: true, length: { minimum: 2, maximum: 50 }, if: -> { required?(:player) }
  validates :minute, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }, if: -> { required?(:minute) }

  def initialize(params, required_fields: [])
    @params = params
    @event_type = params[:event_type]
    @team = params[:team]
    @minute = params[:minute]
    @player = params[:player]
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
