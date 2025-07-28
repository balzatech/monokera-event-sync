class OrdersController < ApplicationController
  before_action :validate_customer_id_param, only: [:index]

  def create
    customer_id = order_params[:customer_id]

    validator = CustomerCacheValidator.new(customer_id)
    unless validator.valid?
      render json: { error: 'Customer not found' }, status: :unprocessable_entity and return
    end

    order = Order.create!(order_params)

    publish_order_created_event(order)

    render json: order, status: :created
  end

  def index
    if params[:customer_id].present?
      orders = Order.where(customer_id: params[:customer_id])
      render json: orders
    else
      render json: { error: 'customer_id param is required' }, status: :bad_request
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
  end

  def validate_customer_id_param
    unless params[:customer_id].present?
      render json: { 
        error: 'Missing parameter', 
        message: 'El parámetro customer_id es requerido' 
      }, status: :bad_request
    end
  end

  def publish_order_created_event(order)
    publisher = Publisher.new
    publisher.publish(
      event: "order_created",
      data: {
        order_id: order.id,
        customer_id: order.customer_id,
      }
    )
    publisher.close
  rescue => e
    Rails.logger.error("Error publishing order event: #{e.message}")
  end
end
