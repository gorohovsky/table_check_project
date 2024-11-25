require 'rails_helper'

describe Order, type: :model do
  let(:product) { create(:product) }
  let(:instance) { Order.new(products: products) }

  describe '#save_updating_products!' do
    subject { instance.save_updating_products! }

    describe 'failure' do
      context 'when stock is lower than requested' do
        let(:products) { { product => 700 } }

        it 'raises a validation error' do
          expect { subject }.to raise_error(Mongoid::Errors::Validations, /Stock must be greater than or equal to 0/)
        end

        it 'does not create an order, modify stock or increase demand' do
          expect { subject }.to raise_error(Mongoid::Errors::Validations).and \
                                not_change { Order.count }.and \
                                not_change { product.reload.stock }.and \
                                not_change { product.reload.demand }
        end
      end
    end

    context 'when stock is sufficient' do
      let(:quantity) { 5 }
      let(:products) { { product => quantity } }

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
        expect(instance.total).to eq 3000
      end
    end
  end
end
