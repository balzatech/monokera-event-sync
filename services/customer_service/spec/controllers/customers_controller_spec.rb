require 'rails_helper'

RSpec.describe CustomersController, type: :controller do
  describe 'GET #index' do
    let!(:customer1) { create(:customer, name: 'John Doe', orders_count: 2) }
    let!(:customer2) { create(:customer, name: 'Jane Smith', orders_count: 5) }
    let!(:customer3) { create(:customer, name: 'Bob Wilson', orders_count: 0) }

    it 'returns all customers' do
      get :index
      
      json_response = JSON.parse(response.body)
      expect(json_response['count']).to eq(3)
      expect(json_response['total_orders']).to eq(7)
    end

    it 'includes customer details in response' do
      get :index
      
      json_response = JSON.parse(response.body)
      customer = json_response['customers'].find { |c| c['name'] == 'John Doe' }
      
      expect(customer).to include(
        'name' => 'John Doe',
        'orders_count' => 2,
        'has_orders' => true
      )
    end
  end

  describe 'GET #show' do
    let(:customer) { create(:customer, name: 'John Doe', address: '123 Main St', orders_count: 3) }

    context 'when customer exists' do
      it 'returns the customer' do
        get :show, params: { id: customer.id }
        
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'id' => customer.id,
          'name' => 'John Doe',
          'address' => '123 Main St',
          'orders_count' => 3,
          'has_orders' => true
        )
      end
    end

    context 'when customer does not exist' do
      it 'returns status :not_found' do
        get :show, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns customer not found error' do
        get :show, params: { id: 999 }
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Customer not found')
        expect(json_response['message']).to eq('Cliente no encontrado')
      end
    end
  end

  describe 'PUT #update' do
    let(:customer) { create(:customer, name: 'John Doe', address: '123 Main St') }

    let(:valid_params) do
      {
        id: customer.id,
        customer: {
          name: 'John Updated',
          address: '456 New St'
        }
      }
    end

    let(:invalid_params) do
      {
        id: customer.id,
        customer: {
          name: '',
          address: 'Too short'
        }
      }
    end

    context 'with valid parameters' do
      it 'updates the customer' do
        put :update, params: valid_params
        
        customer.reload
        expect(customer.name).to eq('John Updated')
        expect(customer.address).to eq('456 New St')
      end

      it 'returns status :ok' do
        put :update, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated customer' do
        put :update, params: valid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response['customer']['name']).to eq('John Updated')
        expect(json_response['customer']['address']).to eq('456 New St')
        expect(json_response['message']).to eq('Cliente actualizado exitosamente')
      end

      it 'invalidates customer cache' do
        expect_any_instance_of(Customer).to receive(:invalidate_cache)
        put :update, params: valid_params
      end
    end

    context 'with invalid parameters' do
      it 'does not update the customer' do
        original_name = customer.name
        put :update, params: invalid_params
        
        customer.reload
        expect(customer.name).to eq(original_name)
      end

      it 'returns status :unprocessable_entity' do
        put :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when customer does not exist' do
      it 'returns status :not_found' do
        put :update, params: { id: 999, customer: { name: 'Test' } }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns customer not found error' do
        put :update, params: { id: 999, customer: { name: 'Test' } }
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Customer not found')
        expect(json_response['message']).to eq('Cliente no encontrado')
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        customer: {
          name: 'New Customer',
          address: '789 New Address St'
        }
      }
    end

    let(:invalid_params) do
      {
        customer: {
          name: '',
          address: 'Short'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new customer' do
        expect {
          post :create, params: valid_params
        }.to change(Customer, :count).by(1)
      end

      it 'returns status :created' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created customer' do
        post :create, params: valid_params
        
        json_response = JSON.parse(response.body)
        expect(json_response['customer']['name']).to eq('New Customer')
        expect(json_response['customer']['address']).to eq('789 New Address St')
        expect(json_response['customer']['orders_count']).to eq(0)
        expect(json_response['customer']['has_orders']).to be false
        expect(json_response['message']).to eq('Cliente creado exitosamente')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a customer' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Customer, :count)
      end

      it 'returns status :unprocessable_entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end