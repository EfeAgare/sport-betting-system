class SessionValidator
  include ActiveModel::Validations

  attr_reader :params

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }

  def initialize(params)
    @params = params
  end

  def validate!
    raise ValidationError, errors.full_messages unless valid?
  end
end
