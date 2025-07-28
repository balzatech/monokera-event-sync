require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    subject { build(:customer) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      it 'sets default orders_count to 0 on create' do
        customer = Customer.new(name: 'Test Customer', address: 'Test Address')
        customer.valid?
        expect(customer.orders_count).to eq(0)
      end

      it 'does not override existing orders_count' do
        customer = Customer.new(name: 'Test Customer', address: 'Test Address', orders_count: 5)
        customer.valid?
        expect(customer.orders_count).to eq(5)
      end
    end
  end

  describe 'instance methods' do
    let(:customer) { build(:customer, orders_count: 3) }

    describe '#has_orders?' do
      it 'returns true when customer has orders' do
        expect(customer.has_orders?).to be true
      end

      it 'returns false when customer has no orders' do
        customer.orders_count = 0
        expect(customer.has_orders?).to be false
      end
    end

    describe '#increment_orders!' do
      it 'increments orders_count by 1' do
        expect { customer.increment_orders! }.to change { customer.orders_count }.by(1)
      end

      it 'saves the record' do
        customer.save!
        expect { customer.increment_orders! }.to change { customer.reload.orders_count }.by(1)
      end
    end

    describe '#invalidate_cache' do
      it 'deletes customer cache from Redis' do
        allow(Rails.cache).to receive(:delete)
        customer.id = 1
        
        customer.invalidate_cache
        
        expect(Rails.cache).to have_received(:delete).with("customer:1")
      end
    end
  end
end