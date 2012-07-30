class User
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :update_at, DateTime

  has n, :accounts

end

class Account
  include DataMapper::Resource

  property :id, Serial
  property :provider, Text
  property :uid, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :user

end
