Sneakers.configure do |config|
  config.amqp = ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672")
  config.workers = 1
  config.worker_paths = ['app/workers']
  config.log_level = Logger::INFO
  config.durable = true
end