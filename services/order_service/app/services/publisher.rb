require 'bunny'
require 'json'

class Publisher
  def initialize
    connection = Bunny.new(ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672"))
    connection.start
    @channel = connection.create_channel
    @exchange = @channel.topic("events", durable: true)
  end

  def publish(event:, data:)
    payload = {
      event: event,
      data: data,
      timestamp: Time.now.utc.iso8601
    }.to_json

    @exchange.publish(payload, routing_key: "order.created", persistent: true)

    Rails.logger.info("Published event #{event}: #{payload}")
  end

  def close
    @channel.connection.close
  end
end
