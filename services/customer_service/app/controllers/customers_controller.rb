class CustomersController < ApplicationController
  def index
    customers = Customer.all
    render json: customers.map { |customer| {
      customer_name: customer.name,
      address: customer.address,
      orders_count: customer.orders_count
    } }
  end

  def show
    customer = Customer.find(params[:id])
    render json: {
      customer_name: customer.name,
      address: customer.address,
      orders_count: customer.orders_count
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Customer not found' }, status: :not_found
  end
end
