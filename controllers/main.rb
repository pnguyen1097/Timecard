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

      helpers do
        def check_exist
          unless params[:project_id].nil?
            halt 404 unless Project.first(:id => params[:project_id], :user_id => session['auth']['user_id'])
          end
        end
      end

      before do
        content_type :json
      end

      # Project collection ==============

      # CREATE a new project
      post '/project' do
        request.body.rewind
        data = JSON.parse(request.body.read)
        project = Project.new
        project.project_name = data['project_name']
        project.for = data['for']
        project.comment = data['comment']
        project.user_id = session['auth']['user_id']
        if project.save
          status 201
          {:id => project.id,
           :project_name => project.project_name,
           :for => project.for,
           :comment => project.comment
          }.to_json
        else
          halt 400, project.errors
        end
      end

      # INDEX all project
      get '/project' do
        check_exist
        Project.all(:user_id => session['auth']['user_id']).to_json
      end

      # READ one project
      get '/project/:project_id' do
        check_exist
        Project.get(params[:project_id]).to_json
      end

      # UPDATE one project
      put '/project/:project_id' do
        check_exist
        request.body.rewind
        data = JSON.parse request.body.read
        project = Project.get(params[:project_id])
        project.project_name = data['project_name'] || "Untitled"
        project.for = data['for'] || ''
        project.comment = data['comment'] || ''
        if project.save
          status 200
          {:id => project.id,
           :project_name => project.project_name,
           :for => project.for,
           :comment => project.comment
          }.to_json
        else
          halt 400, project.errors.to_hash.to_json
        end
      end

      # DELETE one project
      delete '/project/:project_id' do
        check_exist
        project = Project.get(params[:project_id])
        if project.destroy
          status 200
          project.to_json
        else
          halt 400, project.errors.to_hash.to_json
        end
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
