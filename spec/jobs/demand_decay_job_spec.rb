require 'rails_helper'

describe DemandDecayJob, type: :job do
  let(:product) { create(:product) }
  let(:products_hash) { { product => 1 } }

  let(:high_demand) do
    create_list(:order, 10, products: products_hash)
  end

  let(:medium_demand) do
    create_list(:order, 7, products: products_hash)
  end

  let(:low_demand) do
    create_list(:order, 2, products: products_hash)
  end

  subject { described_class.perform_now }

  describe '#perform' do
    it 'does not apply decay for products with high demand (10+ orders)' do
      high_demand
      subject
      expect(product.reload.demand).to eq 120
    end

    it 'applies low decay for products with medium demand (5-9 orders)' do
      medium_demand
      subject
      expect(product.reload.demand).to eq 88
    end

    it 'applies moderate decay for products with low demand (1-3 orders)' do
      low_demand
      subject
      expect(product.reload.demand).to eq 35
    end

    it 'applies the highest decay for products with no orders in the last 24 hours' do
      subject
      expect(product.reload.demand).to eq 20
    end

    it 'does not let the demand go below 0' do
      product.update!(demand: 3)
      subject
      expect(product.reload.demand).to eq 0
    end
  end
end
