module Validatable
  extend ActiveSupport::Concern


  private

  def validate_pagination!
    PaginationValidator.new(
      page: params[:page],
      per_page: params[:per_page]
    ).validate!
  end

  def validate_date_range!
    DateRangeValidator.new(
      params[:start_date],
      params[:end_date]
    ).validate!
  end
end
