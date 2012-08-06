require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/content_for'
require 'sinatra/multi_route'
require 'data_mapper'
require 'omniauth'
require 'omniauth-openid'
require 'openid/store/memory'
require 'sinatra/assetpack'
require 'less'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class App < Sinatra::Base
  
  register Sinatra::Namespace
  register Sinatra::MultiRoute
  helpers Sinatra::ContentFor

  # Rack stuff
  use Rack::Session::Pool
  use OmniAuth::Builder do
    provider :open_id, :store => OpenID::Store::Memory.new, :name => :google, :identifier => 'https://www.google.com/accounts/o8/id'
  end
  OmniAuth.config.on_failure = Proc.new { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }
  # Assets
  register Sinatra::AssetPack

  Less.paths << "app/css"
  assets do
    serve '/js', from: 'public/js'
    js :app, '/js/app.js', [
      '/js/libs/jquery-1.7.2.min.js',
      '/js/libs/modernizr-2.5.3-respond-1.1.0.min.js',
      '/js/libs/bootstrap/transition.js',
      '/js/libs/bootstrap/alert.js',
      '/js/libs/bootstrap/button.js',
      '/js/libs/bootstrap/carousel.js',
      '/js/libs/bootstrap/collapse.js',
      '/js/libs/bootstrap/dropdown.js',
      '/js/libs/bootstrap/modal.js',
      '/js/libs/bootstrap/tooltip.js',
      '/js/libs/bootstrap/popover.js',
      '/js/libs/bootstrap/scrollspy.js',
      '/js/libs/bootstrap/tab.js',
      '/js/libs/bootstrap/typeahead.js',
      '/js/*.js'
    ]
    css :main, '/css/styles.css', [
      '/css/style.css'
    ]
    js_compression :jsmin
    css_compression :simple
  end
  



  get '/' do
    erb :index
  end

  get '/lorem' do
    erb :lorem
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

