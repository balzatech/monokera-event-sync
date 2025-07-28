require 'rails_helper'

RSpec.describe EventConsumers::OrderConsumer do
  describe "#call" do
    let(:customer) { instance_double(Customer, id: 1) }

    context "cuando el cliente existe" do
      before do
        allow(Customer).to receive(:find_by).with(id: 1).and_return(customer)
        allow(customer).to receive(:increment!).with(:orders_count)
        allow(customer).to receive(:invalidate_cache)
      end

      it "incrementa el contador y llama a invalidate_cache" do
        expect(customer).to receive(:increment!).with(:orders_count)
        expect(customer).to receive(:invalidate_cache)
        expect(Rails.logger).to receive(:info).with("orders_count actualizado para el cliente #1")

        consumer = described_class.new(1)
        consumer.call
      end
    end

    context "cuando el cliente NO existe" do
      before do
        allow(Customer).to receive(:find_by).with(id: 99).and_return(nil)
      end

      it "loggea una advertencia y no rompe" do
        expect(Rails.logger).to receive(:warn).with("Cliente no encontrado: 99 en el order consumer")

        consumer = described_class.new(99)
        consumer.call
      end
    end
  end
end
