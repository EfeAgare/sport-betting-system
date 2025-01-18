class RegistrationValidator
  include ActiveModel::Validations

  attr_reader :params

  validates :username, presence: true, length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  def initialize(params)
    @params = params
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end
end
