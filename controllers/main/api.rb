class App < Sinatra::Base
  namespace '/main' do
    namespace '/api' do

      helpers do
        def check_exist
          unless params[:project_id].nil?
            halt 404, 'Project not found' unless Project.first(:id => params[:project_id], :user_id => session['auth']['user_id'])
          end
          unless params[:entry_id].nil?
            halt 404, 'Entry not found' unless Entry.first(:id => params[:entry_id], :project_id => params[:project_id])
          end
        end
      end

      before do
        content_type :json
      end

      # Index accounts
      get '/account' do
        Account.all(:user_id => session['auth']['user_id']).to_json
      end

      delete '/account/:id' do
        acc = Account.first(:user_id => session['auth']['user_id'], :id => params[:id])
        if acc.destroy
          status 200
        else
          halt 400, acc.errors.to_hash.to_json
        end
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
          hash = JSON.parse project.to_json
          hash["numberOfEntries"] = project.entries.count
          hash['totalHours'] = project.totalHours.to_f.round(2)
          hash.to_json
        else
          halt 400, project.errors.to_hash.to_json
        end
      end

      # INDEX all project
      get '/project' do
        check_exist
        array = Array.new
        Project.all(:user_id => session['auth']['user_id']).each do |row|
          hash = JSON.parse row.to_json
          hash["numberOfEntries"] = row.entries.count
          hash["totalHours"] = row.totalHours.to_f.round(2)
          array << hash
        end
        array.to_json
      end

      # READ one project
      get '/project/:project_id' do
        check_exist
        hash = JSON.parse Project.get(params[:project_id]).to_json
        hash["numberOfEntries"] = Project.get(params[:project_id]).entries.count
        hash['totalHours'] = Project.get(params[:project_id]).totalHours.to_f.round(2)
        hash.to_json
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
          hash = JSON.parse project.to_json
          hash["numberOfEntries"] = project.entries.count
          hash['totalHours'] = project.totalHours.to_f.round(2)
          hash.to_json
        else
          halt 400, project.errors.to_hash.to_json
        end
      end

      # DELETE one project
      delete '/project/:project_id' do
        check_exist
        project = Project.get(params[:project_id])
        if project.entries.destroy && project.destroy
          status 200
        else
          halt 400, project.errors.to_hash.to_json
        end
      end

      # =================================

      # Entries collection ==============

      # CREATE an entry
      post '/project/:project_id/entry' do
        check_exist
        request.body.rewind
        data = JSON.parse request.body.read
        entry = Entry.new
        entry.time_in = DateTime.parse(data["time_in"])
        entry.time_out = DateTime.parse(data["time_out"])
        entry.comment = (data["comment"]) || ""
        entry.project_id = params["project_id"]
        entry.user_id = session['auth']['user_id']
        if entry.save
          status 201
          entry.to_json
        else
          halt 400, entry.errors.to_hash.to_json
        end

      end

      # INDEX all entries
      get '/project/:project_id/entry' do
        check_exist
        entries = Entry.all(:project_id => params[:project_id])
        entries.to_json
      end

      # READ an entry
      get '/project/:project_id/entry/:entry_id' do
        check_exist
        entry = Entry.first(:project_id => params[:project_id], :id => params[:entry_id])
        entry.to_json
      end

      # UPDATE an entry
      put '/project/:project_id/entry/:entry_id' do
        check_exist
        request.body.rewind
        data = JSON.parse request.body.read
        entry = Entry.first(:id => params[:entry_id])
        entry.time_in = DateTime.parse(data["time_in"]) unless data["time_in"].nil?
        entry.time_out = DateTime.parse(data["time_out"]) unless data["time_out"].nil?
        entry.comment = data["comment"] unless data["comment"].nil?
        if entry.save
          status 200
          entry.to_json
        else
          halt 400, entry.errors.to_hash.to_json
        end
      end

      # DELETE an entry
      delete '/project/:project_id/entry/:entry_id' do
        check_exist
        entry = Entry.first(:id => params[:entry_id])
        if entry.destroy
          status 200
        else
          halt 400, entry.errors.to_hash.to_json
        end
      end

      # =================================

    end
  end
end
