class OrderEventsWorker
  include Sneakers::Worker

  # Configura el worker para escuchar la cola 'order_events_queue'
  from_queue "order_events_queue",
    durable: true,
    exchange: "events",
    exchange_type: :topic,
    routing_key: "order.created"

  def work(message)
    begin
      payload = JSON.parse(message)

      if payload["event"] == "order_created"
        customer_id = payload.dig("data", "customer_id")
        EventConsumers::OrderConsumer.new(customer_id).call
        ack!
      else
        Rails.logger.info("Evento de orden no gestionado, ignorando: #{payload['event']}")
        ack!
      end
    rescue => e
      Rails.logger.error("Error al procesar evento de orden: #{e.message}")
      reject!
    end
  end
end
