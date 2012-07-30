require 'sinatra/base'
require 'sinatra/namespace'
require 'data_mapper'
require 'omniauth'
require 'omniauth-openid'
require 'openid/store/memory'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class App < Sinatra::Base
  
  register Sinatra::Namespace

  use Rack::Session::Pool
  use OmniAuth::Builder do
    provider :open_id, :store => OpenID::Store::Memory.new, :name => :google, :identifier => 'https://www.google.com/accounts/o8/id'
  end

  get '/' do
    "<a href='/auth/google'>Sign in with Google</a>"
  end
  
  post '/auth/:name/callback' do
    msg = ''
    msg += "<p>UID: #{request.env['omniauth.auth']['uid']} </p>"
    request.env['omniauth.auth']['info'].keys.collect do |key|
      msg += "<p> #{key}: #{request.env['omniauth.auth']['info'][key]}"
    end
    msg
  end

end

Dir['./models/*'].each do |file|
  unless file.to_s[-1..-2] != 'rb'
    require file
  end
end

Dir['./controllers/*'].each do |file|
  unless file.to_s[-1..-2] != 'rb'
    require file
  end
end

require_relative 'helpers/init'

