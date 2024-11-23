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

      product.demand = 30
      expect(product.demand_level).to eq :medium

      product.demand = 15
      expect(product.demand_level).to eq :low

      product.demand = 0
      expect(product.demand_level).to eq :low
    end
  end
end
