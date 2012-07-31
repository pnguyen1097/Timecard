module Foo
  def authorized?

    if session['auth']
      @username = session['auth']['name']
    else
      redirect '/login'
    end

  end
  
end
