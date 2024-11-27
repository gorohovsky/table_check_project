require 'rails_helper'

describe 'Carts', type: :request do
  let(:product) { create(:product) }
  let!(:cart) { create(:cart) }

  describe 'GET /show' do
    subject do
      get "/carts/#{cart.id}"
      response
    end

    context 'when the cart exists' do
      it 'responds with 200 and the cart' do
        expect(subject.status).to eq 200
        expect(JSON.parse(subject.body)).to eq cart.as_json
      end
    end

    context 'when the cart does not exist' do
      let(:cart) { build(:cart) }

      it 'responds with 404 and an error' do
        expect(subject.status).to eq 404
        expect(subject.body).to match(/not found.*#{cart.id}/)
      end
    end
  end

  describe 'POST /add_product' do
    let(:quantity) { 3 }
    let(:total_quantity) { quantity }
    let(:params) { { cart_id: cart.id, product_id: product.id, quantity: } }

    subject do
      post add_product_carts_url, params: params, as: :json
      response
    end

    shared_context 'nonexistent product' do
      let(:product) { build(:product) }
    end

    shared_examples 'nonexistent cart' do
      context 'when the product exists' do
        it_behaves_like 'cart creation'
        it_behaves_like 'cart content response'
      end

      context 'when the product does not exist' do
        include_context 'nonexistent product'
        it_behaves_like 'cart creation'
        it_behaves_like 'product not found response'
      end
    end

    shared_examples 'cart content response' do
      it 'responds with 200 and the cart content' do
        expect(subject.status).to eq 200
        expect(JSON.parse(subject.body)).to include(
          'products' => [{
            'product_id' => product.id.to_s,
            'quantity' => total_quantity
          }],
          'total' => total_quantity * product.default_price
        )
      end
    end

    shared_examples 'cart creation' do
      it 'creates a new cart' do
        expect { subject }.to change { Cart.count }.by 1
      end
    end

    shared_examples 'product not found response' do
      it 'responds with 404 for the product' do
        expect(subject.status).to eq 404
        expect(subject.body).to match(/not found.*#{product.id}/)
      end
    end

    context 'when the cart exists' do
      it 'does not create a new cart' do
        expect { subject }.not_to change { Cart.count }
      end

      context 'when the product exists' do
        it 'adds it to the cart' do
          expect { subject }.to change { cart.reload.products.count }.by 1
        end

        it_behaves_like 'cart content response'

        context 'when it is already in the cart, it adds up the specified quantity' do
          let(:total_quantity) { 5 }
          let!(:cart) { create(:cart, products: [ { product_id: product.id, quantity: 2 } ], total: 1200) }

          it_behaves_like 'cart content response'
        end
      end

      context 'when the product does not exist' do
        include_context 'nonexistent product'
        it_behaves_like 'product not found response'
      end
    end

    context 'when the cart does not exist' do
      let(:cart) { build(:cart) }

      it_behaves_like 'nonexistent cart'
    end

    context 'when no cart_id provided' do
      let(:params) { super().except(:cart_id) }

      it_behaves_like 'nonexistent cart'
    end
  end
end
