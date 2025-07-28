require 'rails_helper'
require 'webmock/rspec'

describe CustomerCacheValidator do
  let(:redis) { instance_double(Redis) }
  let(:customer_id) { 1 }
  let(:cache_key) { "customer:#{customer_id}" }
  let(:response_body) { { id: customer_id, name: "Juan Pérez" }.to_json }

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  context "cuando el customer ya está cacheado" do
    it "devuelve true sin hacer request HTTP" do
      allow(redis).to receive(:get).with(cache_key).and_return(response_body)

      validator = described_class.new(customer_id)
      expect(validator.valid?).to eq(true)
    end
  end

  context "cuando el customer NO está cacheado pero existe en la API" do
    it "hace una petición HTTP, guarda en redis y devuelve true" do
      allow(redis).to receive(:get).with(cache_key).and_return(nil)
      stub_request(:get, "http://customer_web:3000/customers/#{customer_id}")
        .to_return(status: 200, body: response_body)

      expect(redis).to receive(:setex).with(cache_key, 604800, response_body)

      validator = described_class.new(customer_id)
      expect(validator.valid?).to eq(true)
    end
  end

  context "cuando el customer NO existe ni en cache ni en la API" do
    it "devuelve false" do
      allow(redis).to receive(:get).with(cache_key).and_return(nil)
      stub_request(:get, "http://customer_web:3000/customers/#{customer_id}")
        .to_return(status: 404, body: "Not found")

      validator = described_class.new(customer_id)
      expect(validator.valid?).to eq(false)
    end
  end

  context "cuando hay error de red o excepción" do
    it "retorna false y loguea el error" do
      allow(redis).to receive(:get).with(cache_key).and_return(nil)
      allow(CustomerCacheValidator).to receive(:get).and_raise(StandardError.new("Network error"))

      expect(Rails.logger).to receive(:error).with(/Error fetching customer/)

      validator = described_class.new(customer_id)
      expect(validator.valid?).to eq(false)
    end
  end
end
