class User
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :update_at, DateTime

  has n, :accounts
  has n, :projects
  has n, :entries, :through => :projects

end

class Identity
  include DataMapper::Resource
  include OmniAuth::Identity::Models::DataMapper

  property :id, Serial
  property :username, String
  property :password_digest, Text

  attr_accessor :password_confirmation

  self.auth_key :username
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

class Project
  include DataMapper::Resource

  property :id, Serial
  property :project_name, String
  property :for, String
  property :comment, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :user
  has n, :entries
end

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :time_in, DateTime
  property :time_out, DateTime
  property :comment, Text
  property :updated_at, DateTime

  belongs_to :project
  belongs_to :user
end

