class GameService
  CACHE_TRACKER_KEY = "game_data_keys" # Key for tracking cached game data

  # Retrieves a paginated list of games with optional time-based filtering.
  def self.all(page:, per_page:, start_date: nil, end_date: nil)
    game_cache_key = "game_data_page_#{page}_per_page_#{per_page}" # Unique cache key for the current page

    # Track the cache keys to avoid duplicates
    current_keys = Rails.cache.read(CACHE_TRACKER_KEY) || []
    Rails.cache.write(CACHE_TRACKER_KEY, current_keys | [ game_cache_key ]) # Store the current cache key

    # Fetch games from the cache or database
    Rails.cache.fetch(game_cache_key) do
      # Include events and order by creation date
      games = Game.includes(:events).order(created_at: :asc)

      # Apply time-based filtering if start_date and end_date are provided
      if start_date && end_date
        games = games.where(created_at: start_date..end_date)
      end

      # Paginate the results and convert to JSON format, including events
      paginated_games = games.page(page).per(per_page)
      paginated_games_json = paginated_games.page(page).per(per_page).as_json(include: { events: { only: %i[id event_type team minute] } })

      { games: paginated_games_json, meta: {
        current_page: paginated_games&.current_page,
        next_page: paginated_games&.next_page,
        prev_page: paginated_games&.prev_page,
        total_pages: paginated_games&.total_pages,
        total_count: paginated_games&.total_count
      } }.to_json
    end
  end

  # Clears all cached game data
  def self.clear_all_game_cache
    # Read the tracked keys from the cache
    tracked_keys = Rails.cache.read(CACHE_TRACKER_KEY) || []

    # Delete each tracked cache key
    tracked_keys.each { |key| Rails.cache.delete(key) }
    Rails.cache.delete(CACHE_TRACKER_KEY) # Delete the cache tracker key itself
  end

  private

  def pagination_meta(collection)
    {
      current_page: collection&.current_page,
      next_page: collection&.next_page,
      prev_page: collection&.prev_page,
      total_pages: collection&.total_pages,
      total_count: collection&.total_count
    }
  end
end
