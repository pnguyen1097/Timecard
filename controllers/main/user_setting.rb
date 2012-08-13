class App < Sinatra::Base

  namespace '/main' do
    namespace '/user' do

      get '/?' do
        puts "User id = #{session['auth']['user_id']}"
        @accounts = Account.all(:user_id => session['auth']['user_id']).to_json
        erb :user_setting
      end

    end

  end

end
