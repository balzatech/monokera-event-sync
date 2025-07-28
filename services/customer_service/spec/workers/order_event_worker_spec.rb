require 'rails_helper'

RSpec.describe OrderEventsWorker do
  let(:payload) do
    {
      event: 'order_created',
      data: { customer_id: 123 }
    }.to_json
  end

  let(:non_matching_payload) do
    {
      event: 'unrelated_event',
      data: {}
    }.to_json
  end

  subject { described_class.new }

  describe '#work' do
    it 'llama al consumidor cuando el evento es order_created' do
      consumer_double = instance_double(EventConsumers::OrderConsumer)
      expect(EventConsumers::OrderConsumer).to receive(:new).with(123).and_return(consumer_double)
      expect(consumer_double).to receive(:call)
      expect(subject).to receive(:ack!)

      subject.work(payload)
    end

    it 'ignora eventos no relacionados y hace ack' do
      expect(EventConsumers::OrderConsumer).not_to receive(:new)
      expect(subject).to receive(:ack!)

      subject.work(non_matching_payload)
    end

    it 'rechaza el mensaje si hay un error inesperado' do
      # Payload inválido
      bad_payload = 'invalid-json'
      expect(subject).to receive(:reject!)

      subject.work(bad_payload)
    end
  end
end
