class GameService
  CACHE_TRACKER_KEY = "game_data_keys"

  def self.all(page:, per_page:)
    game_cache_key = "game_data_page_#{page}_per_page_#{per_page}"

    # Track the cache keys
    current_keys = Rails.cache.read(CACHE_TRACKER_KEY) || []
    Rails.cache.write(CACHE_TRACKER_KEY, current_keys | [ game_cache_key ]) # Avoid duplicates

    Rails.cache.fetch(game_cache_key) do
      games = Game.includes(:events).order(created_at: :asc).page(page).per(per_page)
      games.as_json(include: { events: { only: %i[id type team minute] } })
    end
  end

  def self.clear_all_game_cache
    tracked_keys = Rails.cache.read(CACHE_TRACKER_KEY) || []

    tracked_keys.each { |key| Rails.cache.delete(key) }
    Rails.cache.delete(CACHE_TRACKER_KEY)
  end
end
