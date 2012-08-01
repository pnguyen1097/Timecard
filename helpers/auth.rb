module Auth
  def authorized?

    if session['auth']
      @username = session['auth']['name']
    else
      return false
    end

  end

  def check_login
    unless authorized? 
      redirect '/login'
    end
  end
  
end
