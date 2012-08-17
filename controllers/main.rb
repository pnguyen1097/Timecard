require_relative './main/api.rb'
require_relative './main/user_setting.rb'
require_relative './main/app.rb'
class App < Sinatra::Base

  namespace '/main' do

    before do
      check_login
    end

    get '/?' do
      "You are #{@username}."
    end

    get '/mock/?' do
      erb :mock
    end

  end

end
