require 'sinatra/base'
require 'sinatra/namespace'
require 'data_mapper'
require 'omniauth'
require 'omniauth-openid'
require 'openid/store/memory'
require 'pp'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class App < Sinatra::Base
  
  register Sinatra::Namespace

  # Rack stuff
  use Rack::Session::Pool
  use OmniAuth::Builder do
    provider :open_id, :store => OpenID::Store::Memory.new, :name => :google, :identifier => 'https://www.google.com/accounts/o8/id'
  end
  
  get '/' do
    "<a href='/auth/google'>Sign in with Google</a>"
  end
  
end

puts "Loading models"
Dir['./models/*'].each do |file|
  unless file.to_s[-2..-1] != 'rb'
    puts file.to_s
    require file
  end
end

DataMapper.auto_upgrade!

puts "Loading controllers"
Dir['./controllers/*'].each do |file|
  unless file.to_s[-2..-1] != 'rb'
    puts file.to_s
    require file
  end
end

require_relative 'helpers/init'

