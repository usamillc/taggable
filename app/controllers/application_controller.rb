class ApplicationController < ActionController::Base
  include SessionsHelper

  def logged_in_annotator
    unless logged_in?
      flash[:danger] = "ログインが必要です。"
      redirect_to login_url
    end
  end

  def logged_in_admin
    unless logged_in? && current_annotator.admin?
      flash[:danger] = "管理者専用ページです。"
      redirect_to root_url
    end
  end

  def merge_allowed_annotator
    unless logged_in?
      session[:merge_tasks] = true
      redirect_to login_url
    end
  end
end
