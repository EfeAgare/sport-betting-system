class JwtBlacklist < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
end
