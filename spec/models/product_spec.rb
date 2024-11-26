require 'rails_helper'

describe Product, type: :model do
  let(:product) { create(:product) }
  let(:value) { 123 }

  describe '#competing_price' do
    subject { product.competing_price }

    context 'when cache is found' do
      before { Rails.cache.write(product.send(:cache_key), value) }

      it "returns competitor's price in cents" do
        expect(subject).to eq value
      end
    end

    context 'when cache is not found' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#update_competing_price' do
    it 'writes a value associated with a specific key to cache' do
      expect(Rails.cache).to \
        receive(:write).with("competing_prices/#{product.id}", value, expires_in: 10_800).and_call_original
      product.update_competing_price value
    end
  end

  describe '#stock_level' do
    it 'return a symbol corresponding to the stock level' do
      product.stock = 1000
      expect(product.stock_level).to eq :very_high

      product.stock = 999
      expect(product.stock_level).to eq :high

      product.stock = 500
      expect(product.stock_level).to eq :high

      product.stock = 499
      expect(product.stock_level).to eq :medium

      product.stock = 50
      expect(product.stock_level).to eq :medium

      product.stock = 49
      expect(product.stock_level).to eq :low

      product.stock = 1
      expect(product.stock_level).to eq :low
    end
  end

  describe '#demand_level' do
    it 'return a symbol corresponding to the demand level' do
      product.demand = 100
      expect(product.demand_level).to eq :high

      product.demand = 99
      expect(product.demand_level).to eq :medium

      product.demand = 40
      expect(product.demand_level).to eq :medium

      product.demand = 30
      expect(product.demand_level).to eq :low

      product.demand = 0
      expect(product.demand_level).to eq :low
    end
  end

  describe '#reduce_stock_by' do
    subject { product.reduce_stock_by(quantity) }

    context 'when stock is sufficient' do
      let(:quantity) { 300 }

      it 'deducts supplied quantity from the stock (without saving)' do
        expect { subject }.to change { product.stock }.by(-quantity)
      end
    end
  end

  describe '#increment_demand' do
    subject { product.increment_demand(event) }

    context 'when added to cart' do
      let(:event) { :cart }

      specify 'demand is increased by 1 (without saving)' do
        expect { subject }.to change { product.demand }.by 1
      end
    end

    context 'when bought' do
      let(:event) { :purchase }

      specify 'demand is increased by 10 (without saving)' do
        expect { subject }.to change { product.demand }.by 10
      end
    end
  end

  describe '#orders' do
    let(:products) { create_list(:product, 2) }
    let(:order1) { create(:order, products: { products[0] => 1, products[1] => 1 }) }
    let(:order2) { create(:order, products: { products[0] => 1 }) }
    let(:order3) { create(:order, products: { products[1] => 1 }) }

    it 'returns orders containing the product' do
      expect(products[0].orders).to contain_exactly(order1, order2)
      expect(products[1].orders).to contain_exactly(order1, order3)
    end
  end
end
