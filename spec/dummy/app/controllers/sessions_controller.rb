class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def show
    
  end

  def create
    @user = User.find_by_name(params[:user][:name])
    # No Authentication!
    session[:user_id] = @user.id
  end

  def destroy
    session.delete(:user_id)
  end
end
