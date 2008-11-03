class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # :secret => '3e944977657f54e55cb20d83a418ff65'
  filter_parameter_logging :password, :confirm_password
  
  helper_method :scoped_url
  
  before_filter :load_company
  before_filter :load_current_user
  
  private
    def load_company
      if params[:company_id]
        @current_company = Company.find_by_id(params[:company_id])
        if @current_company.blank?
          flash[:notice] = "The company specified could not be found"
          redirect_to default_url
          return false
        end
      end
    end
    
    def load_current_user
      @session_owner = (@current_company && @current_company.user_sessions) || UserSession
      @user_owner = (@current_company && @current_company.users) || User
      @user_session = @session_owner.find
      @current_user = @user_session && @user_session.record
    end
    
    def require_user
      unless @current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to scoped_url("new_user_session_url")
        return false
      end
    end
    
    def require_no_user
      if @current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to scoped_url("account_url")
        return false
      end
    end
    
    def prevent_store_location
      @prevent_store_location = true
    end
    
    def scoped_url(unscoped_url, *args)
      if @current_company
        regex = /^(new|edit)_/
        prefix = unscoped_url =~ regex ? "#{$1}_" : ""
        send("#{prefix}company_#{unscoped_url.gsub(regex, "")}", @current_company.id, *args)
      else
        send(unscoped_url, *args)
      end
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
