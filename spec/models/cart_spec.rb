require 'rails_helper'

describe Cart, type: :model do
  let(:product) { create(:product) }
  let(:quantity) { 2 }
  let(:cart) { create(:cart) }

  describe '#add_product!' do
    subject { cart.add_product!(product, quantity) }

    describe 'success' do
      context 'when product is not in cart' do
        it 'adds the product to the cart and adjusts the total' do
          expect { subject }.to change { cart.reload.total }.by 1200
          expect(cart.products.size).to eq 1
          expect(cart.products.first[:product_id]).to eq product.id
          expect(cart.products.first[:quantity]).to eq quantity
        end

        it 'increments the product demand' do
          expect { subject }.to change { product.reload.demand }.by 1
        end
      end

      context 'when product is already in cart' do
        let(:cart) { create(:cart, products: [ { product_id: product.id, quantity: 2 } ], total: 1200) }

        it 'does not add the product' do
          subject
          expect(cart.reload.products.size).to eq 1
        end

        it 'adds up the quantity' do
          subject
          expect(cart.reload.products.first[:quantity]).to eq 4
        end

        it 'adjusts the total' do
          subject
          expect(cart.reload.total).to eq 2400
        end

        it 'increments the product demand' do
          expect { subject }.to change { product.reload.demand }.by 1
        end
      end
    end

    describe 'failure' do
      context 'when quantity is invalid' do
        let(:quantity) { -1 }

        it 'does not add the product to the cart' do
          expect { subject }.to raise_error Mongoid::Errors::Validations
          cart.reload
          expect(cart.products).to be_empty
          expect(cart.total).to eq 0
          expect(cart.errors[:products]).to include 'Quantity must be a positive integer at index 0'
        end

        it 'does not increment the product demand' do
          expect { subject }.to raise_error(Mongoid::Errors::Validations).and \
                                not_change { product.reload.demand }
        end
      end

      context 'when demand increment fails' do
        it 'does not add the product to the cart' do
          expect(product).to receive(:increment_demand!).with(:cart).and_raise StandardError
          expect { subject }.to raise_error StandardError
          cart.reload
          expect(cart.products).to be_empty
          expect(cart.total).to eq 0
        end
      end
    end
  end
end
