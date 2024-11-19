require 'rails_helper'
require 'webmock/rspec' # TODO: possibly move to rails_helper

describe CompetitorClient do
  describe '.fetch_prices' do
    let!(:stub) { stub_request :get, url }

    context 'when a URL passed' do
      let(:url) { 'https://www.example.com' }

      it 'is used instead of the default one' do
        described_class.fetch_prices url
        expect(stub).to have_been_requested
      end
    end

    context 'when URL is not passed' do
      let(:url) { described_class::URL }

      it 'is uses the default URL' do
        described_class.fetch_prices
        expect(stub).to have_been_requested
      end
    end
  end
end
