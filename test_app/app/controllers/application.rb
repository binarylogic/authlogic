class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # :secret => '3e944977657f54e55cb20d83a418ff65'
  filter_parameter_logging :password, :confirm_password
  
  before_filter :load_current_user
  
  private
    def load_current_user
      @user_session = UserSession.find
      @current_user = @user_session && @user_session.record
    end
    
    def require_user
      unless @current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end
    
    def require_no_user
      if @current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    def prevent_store_location
      @prevent_store_location = true
    end
    
    def store_location
      return if @prevent_store_location == true
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      raise (session[:return_to] || default).inspect if (session[:return_to] || default) == nil
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
