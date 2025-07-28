require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    subject { build(:order) }

    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:product_name) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:price) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets default status to pending on create' do
        order = Order.new(
          customer_id: 1,
          product_name: 'Test Product',
          quantity: 1,
          price: 10.0
        )
        order.valid?
        expect(order.status).to eq('pending')
      end
    end
  end

  describe 'instance methods' do
    let(:order) { build(:order, quantity: 3, price: 10.0) }

    describe '#total_amount' do
      it 'calculates total amount correctly' do
        expect(order.total_amount).to eq(30.0)
      end
    end
  end
end