module EventConsumers
  class OrderConsumer
    def initialize(customer_id)
      @customer = Customer.find_by(id: customer_id)
    end

    def call
      if @customer
        @customer.increment!(:orders_count)
        Rails.logger.info("orders_count actualizado para el cliente ##{@customer.id}")
        @customer.invalidate_cache
      else
        Rails.logger.warn("Cliente no encontrado: #{customer_id} en el order consumer")
      end
    end
  end
end
