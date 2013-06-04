#app/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '191030675689.apps.googleusercontent.com', 'ZlXA4ganMmKbSWpZGFfnr8Ag', {
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar',
    redirect_uri:'http://localhost/auth/google_oauth2/callback'
  }
end
