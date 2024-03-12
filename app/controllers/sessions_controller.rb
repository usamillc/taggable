class SessionsController < ApplicationController
  def new
  end

  def create
    annotator = Annotator.find_by(username: params[:session][:username])
    if annotator && annotator.authenticate(params[:session][:password])
      log_in annotator
      remember annotator
      if session[:merge_tasks]
        session[:merge_tasks] = nil
        redirect_to merge_tasks_url
      else
        redirect_to tasks_url
      end
    else
      flash.now[:danger] = 'usernameとpasswordが一致しません。'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_path
  end
end
