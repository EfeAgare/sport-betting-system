module Helpers
  extend ActiveSupport::Concern

  def safe_parse_date(date_str)
    return nil if date_str.blank?

    DateTime.parse(date_str) rescue nil
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end
