class Customer < ApplicationRecord
  validates :name, :address, presence: true
end
