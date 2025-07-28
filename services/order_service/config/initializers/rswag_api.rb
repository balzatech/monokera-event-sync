Rswag::Api.configure do |c|

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  c.swagger_root = Rails.root.join('swagger').to_s

  # Inject a lambda function to alter the returned Swagger prior to serialization
  # The function will have access to the rack env for the current request
  # For example, you can leverage this to dynamically assign the "host" property
  #
  # c.swagger_filter = lambda { |swagger, env| swagger['host'] = env['HTTP_HOST'] }
end