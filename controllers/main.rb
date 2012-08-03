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
