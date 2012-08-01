class App < Sinatra::Base

  namespace '/main' do

    before do
      check_login
    end

    get '/?' do
      puts session
      "You are #{@username}."
    end

  end

end
