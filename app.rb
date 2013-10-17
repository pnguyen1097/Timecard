
require_relative './initializers/init.rb'

class App < Sinatra::Base

  before do
    @flash = session[:flash] || {}
    session[:flash] = nil
  end

  get '/' do
    erb :index
  end

  get '/lorem' do
    erb :lorem
  end

  include Initializers
end

require_relative 'helpers/init'

