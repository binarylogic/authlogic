class UserSessionsController < ApplicationController
  before_filter :prevent_store_location, :only => [:destroy, :create]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.create
      flash[:notice] = "Login successful!"
      redirect_back_or_default(account_url)
    else
      render :action => :new
    end
  end
  
  def destroy
    @user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default(new_user_session_url)
  end
end
