# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Customer.find_or_create_by!(name: 'brayan alzate', address: 'Calle 123', orders_count: 0)
Customer.find_or_create_by!(name: 'carmen ruiz', address: 'Avenida 456', orders_count: 0)
Customer.find_or_create_by!(name: 'jhonny alzate', address: 'Carrera 789', orders_count: 0)
