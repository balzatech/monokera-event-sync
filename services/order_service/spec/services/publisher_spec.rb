require 'rails_helper'

describe Publisher do
  let(:bunny_connection) { instance_double(Bunny::Session) }
  let(:channel) { instance_double(Bunny::Channel) }
  let(:exchange) { instance_double(Bunny::Exchange) }

  before do
    allow(Bunny).to receive(:new).and_return(bunny_connection)
    allow(bunny_connection).to receive(:start)
    allow(bunny_connection).to receive(:create_channel).and_return(channel)
    allow(channel).to receive(:topic).with("events", durable: true).and_return(exchange)
    allow(exchange).to receive(:publish)
  end

  describe "#publish" do
    it "publica el evento en el exchange con la routing key correcta" do
      allow(channel).to receive(:connection).and_return(bunny_connection)
      allow(bunny_connection).to receive(:close)

      publisher = Publisher.new

      expect(exchange).to receive(:publish).with(
        a_string_including("order_id"),
        hash_including(routing_key: "order.created", persistent: true)
      )

      expect(Rails.logger).to receive(:info).with(/Published event/)

      publisher.publish(
        event: "order_created",
        data: { order_id: 123, customer_id: 1 }
      )

      publisher.close
    end
  end
end
