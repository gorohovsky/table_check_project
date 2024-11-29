require 'rails_helper'

describe Order, type: :model do
  let(:product) { create(:product) }
  let(:order) { build(:order, products: [product], quantity:) }

  describe '#save_updating_products!' do
    subject { order.save_updating_products! }

    context 'when stock is lower than requested' do
      let(:quantity) { 700 }

      it 'raises a validation error' do
        expect { subject }.to raise_error(Mongoid::Errors::Validations, /Stock must be greater than or equal to 0/)
      end

      it 'does not create an order, modify stock or increase demand' do
        expect { subject }.to raise_error(Mongoid::Errors::Validations).and \
                              not_change { Order.count }.and \
                              not_change { product.reload.stock }.and \
                              not_change { product.demand }
      end
    end

    context 'when stock is sufficient' do
      let(:quantity) { 5 }

      it 'creates a new order' do
        expect { subject }.to change { Order.count }.by 1
      end

      it 'deducts ordered quantity of products from stock' do
        expect { subject }.to change { product.reload.stock }.by(-quantity)
      end

      it 'increments product demand' do
        expect { subject }.to change { product.reload.demand }.by 10
      end

      it 'sets correct total' do
        subject
        expect(order.total).to eq 3000
      end
    end
  end

  describe '#add_product' do
    let(:quantity) { 5 }
    let(:order) { build(:order) }

    subject { order.add_product(product, quantity) }

    it 'adds the product and the quantity to order items' do
      expect(order.order_items).to be_empty
      subject
      expect(order.order_items.size).to eq 1
      expect(order.order_items.first).to have_attributes(
        product:,
        quantity:,
        product_id: product.id,
        product_name: product.name,
        price: product.dynamic_price
      )
    end
  end
end
