class App < Sinatra::Base

  namespace '/main' do
    namespace '/app' do


      before do
        # FOR TESTING ONLY==========
        #session['auth'] = Hash.new
        #session['auth']['user_id'] = 2
        #session['auth']['name'] = "Mark Nguyen"
        #session['auth']['uid'] = "https://www.google.com/accounts/o8/id?id=AItOawm_DNI2mQM77rx6dbKe7dedUxsj-elvrHA"
        # ================
        check_login

        # Common variables here
        # Project list
        @projects = Project.all(:user_id => session['auth']['user_id'], :order => [:last_entry_updated_at.desc])
      end

      get '/?' do
        erb :'/main/overview'
      end
    end

  end
end
