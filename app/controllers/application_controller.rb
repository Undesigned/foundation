class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login

  def require_login
    current_user
  end

  def current_user
    raise Exceptionally::Unauthorized.new('Unauthorized user') unless session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end
end
