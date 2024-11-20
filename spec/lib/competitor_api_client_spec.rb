require 'rails_helper'
require 'webmock/rspec' # TODO: possibly move to rails_helper

describe CompetitorApi::Client do
  describe '.fetch_data' do
    let(:url) { described_class::URL }

    describe 'request' do
      let!(:stub) do
        stub_request(:get, url)
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(body: '{}', headers: { content_type: 'application/json' })
      end

      context 'when a URL passed' do
        let(:url) { 'https://www.example.com' }

        it 'is used instead of the default one' do
          described_class.fetch_data url
          expect(stub).to have_been_requested
        end
      end

      context 'when URL is not passed' do
        it 'is uses the default URL' do
          described_class.fetch_data
          expect(stub).to have_been_requested
        end
      end
    end

    describe 'response' do
      subject { described_class.fetch_data }

      context 'when status code is 2XX' do
        it 'returns parsed response', vcr: 'competitor/200' do
          expect(subject).to be_a Array
        end
      end

      context 'when status code differs from 2XX' do
        it 'raises BadResponse error', vcr: 'competitor/500' do
          expect { subject }.to raise_error CompetitorApi::Errors::BadResponse
        end
      end
    end
  end
end
