class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to account_path
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
  end
  
  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = "Account updated!"
      redirect_to account_path
    else
      render :action => :edit
    end
  end
end
