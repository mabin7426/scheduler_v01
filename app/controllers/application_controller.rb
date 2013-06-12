class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  Time.zone = 'America/Chicago'
  # Time.zone.local
  # x = Event.create(it_will_happen_at: Time.zone.now)
  # x.it_will_happen_at

end
