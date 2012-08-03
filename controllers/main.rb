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

    namespace '/api' do

      # Project collection ==============

      # CREATE a new project
      post '/project' do
        
      end

      # INDEX all project
      get '/project' do

      end

      # READ one project
      get '/project/:project_id' do

      end

      # UPDATE one project
      put '/project/:project_id' do

      end

      # DELETE one project
      delete '/project/:project_id' do

      end

      # =================================

      # Entries collection ==============

      # CREATE an entry
      post '/project/:project_id/entries' do

      end

      # INDEX all entries
      get '/project/:project_id/entries' do

      end

      # READ an entry
      get '/project/:project_id/entries/:entry_id' do

      end

      # UPDATE an entry
      put '/project/:project_id/entries/:entry_id' do

      end

      # DELETE an entry
      delete '/project/:project_id/entries/:entry_id' do

      end

      # =================================

    end

  end

end
