class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update]
  before_filter :load_user, :except => [:new, :create]
  
  def new
    @user = @user_owner.new
  end
  
  def create
    @user = @user_owner.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to scoped_url("account_path")
    else
      render :action => :new
    end
  end
  
  def show
    if @user
      @user.update_attribute(:profile_views, @user.profile_views + 1) if @user && params[:id]
    else
      flash[:notice] = "We're sorry, but no user was found"
      redirect_to scoped_url("new_user_session_url")
    end
  end
  
  # This is a method created for tests only, to make sure users logged out get logged in when changing passwords
  def reset_password
    if @user
      @user.password = "saweet"
      @user.confirm_password = "saweet"
      @user.save
    else
      flash[:notice] = "We're sorry, but no user was found"
      redirect_to scoped_url("new_user_session_url")
    end
  end
  
  def update
    @user = @current_user
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = "Account updated!"
      redirect_to scoped_url("account_path")
    else
      render :action => :edit
    end
  end
  
  private
    def load_user
      if params[:id]
        @user = @user_owner.find_by_id(params[:id])
        @user.update_attribute(:profile_views, @user.profile_views + 1) if @user
      else
        @user = @current_user
      end
    end
end
