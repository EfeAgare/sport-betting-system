class UserValidator
  include ActiveModel::Validations

  attr_accessor :username, :email, :password, :balance, :required_fields

  validates :username, presence: true, length: { minimum: 3, maximum: 30 }, if: -> { required?(:username) }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { required?(:email) }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { required?(:password) }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { required?(:balance) }

  def initialize(params, required_fields: [])
    @username = params[:username]
    @password = params[:password]
    @email = params[:email]
    @balance = params[:balance]
    @required_fields = required_fields
  end

  def validate!
    raise ValidationError, errors.full_messages.join(", ") unless valid?
  end

  private

  def required?(field)
    required_fields.include?(field)
  end
end
