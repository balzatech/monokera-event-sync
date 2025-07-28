class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :update]

  def index
    customers = Customer.all
    
    render json: {
      customers: customers.map { |customer| customer_response(customer) },
      count: customers.count,
      total_orders: customers.sum(:orders_count)
    }
  end

  def show
    render json: customer_response(@customer)
  rescue ActiveRecord::RecordNotFound
    render json: { 
      error: 'Customer not found',
      message: 'Cliente no encontrado'
    }, status: :not_found
  end

  def update
    if @customer.update(customer_params)
      @customer.invalidate_cache

      render json: {
        customer: customer_response(@customer),
        message: 'Cliente actualizado exitosamente'
      }
    else
      render json: {
        error: 'Validation failed',
        errors: @customer.errors.full_messages,
        customer: customer_response(@customer)
      }, status: :unprocessable_entity
    end
  end

  def create
    customer = Customer.new(customer_params)
    
    if customer.save
      render json: {
        customer: customer_response(customer),
        message: 'Cliente creado exitosamente'
      }, status: :created
    else
      render json: {
        error: 'Validation failed',
        errors: customer.errors.full_messages,
        customer: customer_response(customer)
      }, status: :unprocessable_entity
    end
  end
  
  private

  def set_customer
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { 
      error: 'Customer not found',
      message: 'Cliente no encontrado'
    }, status: :not_found
  end

  def customer_params
    params.require(:customer).permit(:name, :address)
  end

  def customer_response(customer)
    {
      id: customer.id,
      name: customer.name,
      address: customer.address,
      orders_count: customer.orders_count,
      has_orders: customer.has_orders?,
      created_at: customer.created_at,
      updated_at: customer.updated_at
    }
  end
end
