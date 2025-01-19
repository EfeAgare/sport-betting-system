class GameValidator
  include ActiveModel::Validations

  attr_accessor :home_team, :away_team, :home_score, :away_score, :time_elapsed, :status, :events_attributes, :required_fields

  validates :home_team, presence: true, length: { minimum: 2, maximum: 50 }, if: -> { required?(:home_team) }
  validates :away_team, presence: true, length: { minimum: 2, maximum: 50 }, if: -> { required?(:away_team) }
  validates :home_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { required?(:home_score) }
  validates :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { required?(:away_score) }
  validates :time_elapsed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: -> { required?(:time_elapsed) }
  validates :status, presence: true, inclusion: { in: %w[scheduled ongoing paused finished cancelled postponed abandoned], message: "must be of type: scheduled ongoing paused finished cancelled postponed abandoned" }, if: -> { required?(:status) }
  validate :validate_events_attributes, if: -> { required?(:events_attributes) }

  def initialize(params, required_fields: [])
    @params = params
    @home_team = params[:home_team]
    @away_team = params[:away_team]
    @home_score = params[:home_score]
    @away_score = params[:away_score]
    @time_elapsed = params[:time_elapsed]
    @status = params[:status]
    @events_attributes = params[:events_attributes]
    @required_fields = required_fields
  end

  def validate!
    raise ValidationError, errors.full_messages.join(", ") unless valid?
  end

  private

  def required?(field)
    required_fields.include?(field)
  end

  def validate_events_attributes
    if events_attributes.blank? || !events_attributes.is_a?(Array)
      errors.add(:events_attributes, "must be a non-empty array")
      return
    end

    events_attributes.each_with_index do |event, index|
      [ :event_type, :team, :player, :minute ].each do |attribute|
        if event[attribute].blank?
          errors.add(:events_attributes, "at index #{index} is missing required attribute: #{attribute}")
        end
      end
    end
  end
end
