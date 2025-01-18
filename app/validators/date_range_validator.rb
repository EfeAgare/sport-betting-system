class DateRangeValidator
  include ActiveModel::Validations

  attr_reader :start_date, :end_date

  validate :date_range_valid

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end

  private

  def date_range_valid
    return if start_date.nil? || end_date.nil?

    begin
      parsed_start = DateTime.parse(start_date.to_s)
      parsed_end = DateTime.parse(end_date.to_s)

      if parsed_end < parsed_start
        errors.add(:base, "End date must be after start date")
      end

      if parsed_start > DateTime.now
        errors.add(:base, "Start date cannot be in the future")
      end
    rescue ArgumentError
      errors.add(:base, "Invalid date format")
    end
  end
end
