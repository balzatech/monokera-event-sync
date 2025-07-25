require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  let!(:customer1) { Customer.create!(name: 'Juan Perez', address: 'Calle 123', orders_count: 2) }
  let!(:customer2) { Customer.create!(name: 'Maria Gomez', address: 'Avenida 456', orders_count: 5) }

  describe 'GET #index' do
    it 'returns a list of customers' do
      get :index
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.first).to include('customer_name' => customer1.name, 'address' => customer1.address, 'orders_count' => customer1.orders_count)
    end
  end

  describe 'GET #show' do
    it 'returns the customer when found' do
      get :show, params: { id: customer2.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include('customer_name' => customer2.name, 'address' => customer2.address, 'orders_count' => customer2.orders_count)
    end

    it 'returns 404 when customer not found' do
      get :show, params: { id: 99999 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Customer not found')
    end
  end
end 