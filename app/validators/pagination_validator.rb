class PaginationValidator
  include ActiveModel::Validations

  attr_accessor :page, :per_page

  validates :page, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :per_page, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def initialize(params)
    @page = params[:page]
    @per_page = params[:per_page]
  end

  def validate!
    raise ValidationError, errors.full_messages.join(", ") unless valid?
  end
end
