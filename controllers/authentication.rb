class App < Sinatra::Base

  # User session hash
  # session['auth']['name']
  #                ['provider']
  #                ['uid']
  #                ['user_id']

    route :get, :post, '/auth/:provider/callback' do
      # If logged in, check if account exist and associate with current user
      # If not logged in, check if account exist, log that account.user in, 
      # If account doesn't exist, create new account + new user

      omniauth = request.env['omniauth.auth']
      currentAuth = session['auth']
      if session['auth']
        if omniauth['uid'] != currentAuth['uid']
          account = Account.new
          account.provider = omniauth['provider']
          account.uid = omniauth['uid']
          account.user_id = currentAuth['user_id']
          account.save
        end
        account = Account.first(:provider => omniauth['provider'], :uid => omniauth['uid'])
      else
        account = Account.first_or_new(:provider => omniauth['provider'], :uid => omniauth['uid'])
        if account.user.nil?
          account.user = User.create
        end
        account.save
      end

      session['auth'] = {'name' => omniauth['info']['name'], 'provider' => account.provider, 'uid' => account.uid, 'user_id' => account.user.id}

      redirect '/'

    end

    get '/auth/failure' do
      redirect '/login'
    end

    get '/logout' do
      session['auth'] = nil
      redirect '/'
    end

    get '/login' do
      erb :login
    end

end
