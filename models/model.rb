class User
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :update_at, DateTime

  has n, :accounts
  has n, :projects

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
end

