class App < Sinatra::Base

  namespace '/main' do
    namespace '/app' do


      before do
        # FOR TESTING ONLY==========
        session['auth'] = Hash.new
        session['auth']['user_id'] = 2
        session['auth']['name'] = "Mark Nguyen"
        session['auth']['uid'] = "https://www.google.com/accounts/o8/id?id=AItOawm_DNI2mQM77rx6dbKe7dedUxsj-elvrHA"
        # ================
        check_login

        # Common variables here
        # Project list
        @projects = Project.all(:user_id => session['auth']['user_id'], :order => [:last_entry_updated_at.desc])
      end

      get '/?' do
        erb :'/main/overview'
      end

      get '/project/:project_id' do
        project = Project.first(:id => params[:project_id], :user_id => session['auth']['user_id'])
        if project.nil?
          @found = false
          @entries = {}.to_json
        else
          @found = true

          # Which page
          if params[:page].nil?
            page = 1
          else
            page = params[:page].to_i
          end
          #How many per page
          if params[:limit].nil?
            limit = 31
          else
            limit = params[:limit].to_i
          end
          offset = (page - 1) * limit
          # Search query
          query = params[:q] || ""
          # Date range
          startdate, enddate = nil
          unless params[:startdate].nil?
            startdate = DateTime.parse(params[:startdate])
            if params[:enddate].nil?
              enddate = DateTime.now
            else
              enddate = DateTime.parse(params[:enddate])
            end
          end
          # Build option hash
          opts = Hash.new
          opts[:order] = [:time_in.desc]
          opts[:offset] = offset
          opts[:limit] = limit
          opts[:comment.like] = query unless query == ""
          opts[:time_in.gte] = startdate unless startdate.nil?
          opts[:time_in.lte] = enddate unless enddate.nil?

          @entries = project.entries.all(opts)
          erb :"/main/project"
        end

      end
    end

  end
end
