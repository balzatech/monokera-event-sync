class OrdersController < ApplicationController
  def create
    customer_id = order_params[:customer_id]

    validator = CustomerCacheValidator.new(customer_id)
    unless validator.valid?
      render json: { error: 'Customer not found 1' }, status: :unprocessable_entity and return
    end

    order = Order.create!(order_params)

    publisher = Publisher.new
    publisher.publish(
      event: "order_created",
      data: {
        order_id: order.id,
        customer_id: order.customer_id,
      }
    )
    publisher.close

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
end
