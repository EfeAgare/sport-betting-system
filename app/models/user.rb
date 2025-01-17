# frozen_string_literal: true

class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  before_create :set_default_balance

  private

  def set_default_balance
    self.balance ||= 0
  end
end
