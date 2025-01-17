class EventSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :event_type, :team, :player, :minute, :created_at, :updated_at
end
