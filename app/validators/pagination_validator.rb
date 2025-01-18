class PaginationValidator
  include ActiveModel::Validations

  attr_reader :params

  validates :page, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :per_page, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def initialize(params)
    @params = params
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end
end
