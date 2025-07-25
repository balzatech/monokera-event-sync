require 'rails_helper'

RSpec.describe Customer, type: :model do
  subject { described_class.new(name: 'Test Name', address: 'Test Address', orders_count: 0) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is not valid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without an address' do
      subject.address = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:address]).to include("can't be blank")
    end

    it 'is valid without orders_count' do
      subject.orders_count = nil
      expect(subject).to be_valid
    end
  end
end
