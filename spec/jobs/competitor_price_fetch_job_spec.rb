require 'rails_helper'

describe CompetitorPriceFetchJob, type: :job do
  let(:category) { create(:category, name: 'Accessories') }
  let(:products) do
    ['DeLorean Jacket', 'Batman Costume'].map do |name|
      create(:product, name:, category:)
    end
  end
  let(:matching_product) { products[0] }
  let(:non_matching_product) { products[1] }

  subject { described_class.perform_now }

  describe 'correct API response' do
    it 'updates competing prices for matching products', vcr: 'competitor/200' do
      products.each { expect(_1.competing_price).to be_nil }

      expect { subject }.to \
        change { matching_product.competing_price }.from(nil).to(7450).and \
        not_change { non_matching_product.competing_price }
    end
  end

  describe 'error API response' do
    it 'does not update products', vcr: 'competitor/500' do
      expect { subject }.to \
        raise_error(CompetitorApi::Errors::BadResponse).and \
        not_change { matching_product.competing_price }.and \
        not_change { non_matching_product.competing_price }
    end

    it 'is requeued 5 times' do
      expect(described_class).to be_retryable 5
    end
  end
end
