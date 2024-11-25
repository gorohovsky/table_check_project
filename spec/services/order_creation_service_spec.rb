require 'rails_helper'

describe OrderCreationService do
  describe '#execute' do
    let(:products) { create_list(:product, 3) }
    let(:order_params) { products_to_order_params(products) }

    subject { described_class.new(order_params).execute }

    it 'instantiates Order and proceeds with saving' do
      expect(Order).to receive(:new).with(
        products: { products[0] => 1, products[1] => 2, products[2] => 3 }
      ).and_call_original

      expect_any_instance_of(Order).to receive :save_updating_products!
      subject
    end

    shared_examples 'raised exception' do |exception|
      it 'raises a corresponding error and does not create an order' do
        expect { subject }.to raise_error(exception).and not_change { Order.count }
      end
    end

    context 'when all products exist' do
      context 'when sufficient stock' do
        it 'creates an order' do
          expect { subject }.to change { Order.count }.by 1
        end

        it 'returns an Order object' do
          expect(subject).to be_a Order
        end
      end

      context 'when insufficient stock' do
        let(:order_params) { products_to_order_params(products, 250) }

        it_behaves_like 'raised exception', Mongoid::Errors::Validations
      end
    end

    context 'when at least one product does not exist' do
      before { products.sample.destroy }

      it_behaves_like 'raised exception', described_class::ProductsNotFound
    end
  end
end
