class GameValidator
  include ActiveModel::Validations

  attr_reader :params

  validates :home_team, presence: true, length: { minimum: 2, maximum: 50 }
  validates :away_team, presence: true, length: { minimum: 2, maximum: 50 }
  validates :home_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_elapsed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[scheduled ongoing paused finished cancelled postponed abandoned] }
  validates :events_attributes, presence: true, if: -> { params[:events_attributes].present? }

  def initialize(params)
    @params = params
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end
end
