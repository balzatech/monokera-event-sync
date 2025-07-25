require 'swagger_helper'

RSpec.describe 'Customers API', swagger_doc: 'v1/swagger.yaml' do
  path '/customers/{id}' do
    get 'Get a customer by ID' do
      tags 'Customers'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'customer found' do
        let(:id) { Customer.create!(customer_name: "Julián", address: "Av 123").id }

        run_test!
      end

      response '404', 'customer not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
