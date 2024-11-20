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
end
