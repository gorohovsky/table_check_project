require 'rails_helper'

describe '/orders', type: :request do
  let(:products) { create_list(:product, 2) }

  let(:valid_attributes) do
    { products: products_to_order_params(products) }
  end

  let(:invalid_attributes) do
    { products: products_to_order_params(products, 0) }
  end

  describe 'POST /create' do
    subject do
      post orders_url, params: { order: attributes }, as: :json
      response
    end

    context 'with valid parameters' do
      let(:attributes) { valid_attributes }

      it 'creates a new order' do
        expect { subject }.to change { Order.count }.by 1
      end

      it 'responds with 201 and the serialized order' do
        expect(subject.status).to eq 201
        expect(JSON.parse(subject.body)).to include(
          'order_products' => [
            include('quantity' => 1, 'product_id' => products[0].id, 'product_name' => products[0].name, 'price' => 600),
            include('quantity' => 2, 'product_id' => products[1].id, 'product_name' => products[1].name, 'price' => 600)
          ],
          'total' => 1800
        )
      end
    end

    shared_examples 'error response' do |status_code, error_message|
      it 'does not create a new order' do
        expect { subject }.to change { Order.count }.by 0
      end

      it "responds with #{status_code} and errors" do
        expect(subject.status).to eq status_code
        expect(subject.body).to match error_message
      end
    end

    context 'with invalid parameters' do
      let(:attributes) { invalid_attributes }
      it_behaves_like 'error response', 400, 'products.*qty.*must be greater than 0'
    end

    context 'when insufficient stock' do
      let(:attributes) { { products: products_to_order_params(products, 500) } }
      it_behaves_like 'error response', 422, 'stock.*must be greater than or equal to 0'
    end

    context 'when some products do not exist' do
      let(:attributes) { valid_attributes }
      before { products.sample.destroy }
      it_behaves_like 'error response', 400, 'Provided invalid products'
    end
  end
end
