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
  property :username, String, :unique => true, :required => true
  property :name, String
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
  property :last_entry_updated_at, DateTime, :default => lambda { |r, p| DateTime.now }
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :user
  has n, :entries

  before :save, :update_time

  def totalHours
    total = 0
    self.entries.each do |entry|
      total += (entry.time_out - entry.time_in) * 24
    end
    return total
  end

  def update_time
    self.last_entry_updated_at = DateTime.now
  end
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

  before :save, :updateProject
  before :create, :updateProject

  def updateProject
    p = self.project
    p.last_entry_updated_at = DateTime.now
    p.save
  end
end

