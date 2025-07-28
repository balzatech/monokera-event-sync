require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        order: {
          customer_id: 1,
          product_name: 'Test Product',
          quantity: 2,
          price: 10.0,
          status: 'pending'
        }
      }
    end

    let(:invalid_params) do
      {
        order: {
          customer_id: 1,
          product_name: '',
          quantity: 0,
          price: -5.0,
          status: ''
        }
      }
    end

    context 'with valid parameters' do
      before do
        allow_any_instance_of(CustomerCacheValidator).to receive(:valid?).and_return(true)
        allow_any_instance_of(Publisher).to receive(:publish).and_return(true)
        allow_any_instance_of(Publisher).to receive(:close).and_return(true)
      end

      it 'creates a new order' do
        expect {
          post :create, params: valid_params
        }.to change(Order, :count).by(1)
      end

      it 'returns status :created' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'publishes an order_created event' do
        publisher = instance_double(Publisher)
        allow(Publisher).to receive(:new).and_return(publisher)
        allow(publisher).to receive(:publish)
        allow(publisher).to receive(:close)

        post :create, params: valid_params

        expect(publisher).to have_received(:publish).with(
          event: 'order_created',
          data: {
            order_id: kind_of(Integer),
            customer_id: 1
          }
        )
      end
    end

    context 'with invalid parameters' do
      before do
        allow_any_instance_of(CustomerCacheValidator).to receive(:valid?).and_return(true)
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect {
          post :create, params: invalid_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when customer does not exist' do
      before do
        allow_any_instance_of(CustomerCacheValidator).to receive(:valid?).and_return(false)
      end

      it 'does not create an order' do
        expect {
          post :create, params: valid_params
        }.not_to change(Order, :count)
      end

      it 'returns status :unprocessable_entity' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns customer not found error' do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Customer not found')
      end
    end

    context 'when publisher fails' do
      before do
        allow_any_instance_of(CustomerCacheValidator).to receive(:valid?).and_return(true)
        allow_any_instance_of(Publisher).to receive(:publish).and_raise(StandardError.new('Publisher error'))
        allow_any_instance_of(Publisher).to receive(:close).and_return(true)
      end

      it 'still creates the order' do
        expect {
          post :create, params: valid_params
        }.to change(Order, :count).by(1)
      end

      it 'returns status :created' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'GET #index' do
    let!(:order1) { create(:order, customer_id: 1, product_name: 'Product 1') }
    let!(:order2) { create(:order, customer_id: 1, product_name: 'Product 2') }
    let!(:order3) { create(:order, customer_id: 2, product_name: 'Product 3') }

    context 'with valid customer_id parameter' do
      it 'returns orders for the specified customer' do
        get :index, params: { customer_id: 1 }

        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)

        order_names = json_response.map { |o| o['product_name'] }
        expect(order_names).to include('Product 1', 'Product 2')
      end
    end

    context 'without customer_id parameter' do
      it 'returns status :bad_request' do
        get :index
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns missing parameter error' do
        get :index
        json_response = JSON.parse(response.body)

        expect(json_response['error']).to eq('Missing parameter')
        expect(json_response['message']).to eq('El parámetro customer_id es requerido')
      end
    end

    context 'with non-existent customer_id' do
      it 'returns empty orders list' do
        get :index, params: { customer_id: 999 }

        json_response = JSON.parse(response.body)
        expect(json_response).to eq([])
      end
    end
  end
end
