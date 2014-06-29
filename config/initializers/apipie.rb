Apipie.configure do |config|
  config.app_name                = "Found API"
  config.copyright               = "&copy; #{Date.today.year.to_s} Undesigned."
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  # were is your API defined?
  config.api_controllers_matcher = "{#{Rails.root}}/app/controllers/*.rb"

  config.app_info = "
    This is an API for Found.
  "
end
