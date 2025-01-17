class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :balance, :created_at, :updated_at
end
