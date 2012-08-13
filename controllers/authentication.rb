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
      if currentAuth
          account = Account.first_or_new(:provider => omniauth['provider'], :uid => omniauth['uid'], :user_id => currentAuth['user_id'])
          account.save
      else
        account = Account.first_or_new(:provider => omniauth['provider'], :uid => omniauth['uid'])
        if account.user.nil?
          account.user = User.create
        end
        account.save
      end

      session['auth'] = {'name' => omniauth['info']['name'], 'provider' => account.provider, 'uid' => account.uid, 'user_id' => account.user.id}

      if env['omniauth.origin'].match('/login')
        redirect '/main/app'
      else
        redirect env['omniauth.origin']
      end

    end

    get '/auth/failure' do
      if params[:strategy] == "identity"
        session[:flash] = {"identity.error" => "Invalid username or password. Please try again."}
      else
        session[:flash] = {"provider.error" => "There was a problem signing in with your selected provider."}
      end
      redirect params[:origin]
    end

    get '/logout' do
      session['auth'] = nil
      redirect '/'
    end

    get '/login' do
      erb :login
    end

    get '/register' do
      unless params.length == 0
        @flash ||= Hash.new
        params.keys.each do |key|
          @flash[key] = params[key]
        end
      end
      erb :register
    end

    post '/register/check_username' do
      # return true if username already exist
      content_type :json
      if Identity.first(:username => params[:username])
        true.to_json
      else
        false.to_json
      end
    end

end
