Rails.application.config.middleware.use OmniAuth::Builder do
  provider :angellist, ENV['ANGELLIST_KEY'], ENV['ANGELLIST_SECRET']
end