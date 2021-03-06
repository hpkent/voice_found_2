Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.secrets.client_id, Rails.application.secrets.client_secret, 
  {
  scope: ['email', 
    'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/calendar.readonly'],
  access_type: 'offline',
  prompt: 'consent',
  skip_jwt: true
}
end
