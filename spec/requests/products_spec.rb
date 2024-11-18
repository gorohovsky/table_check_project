require 'rails_helper'

describe '/products', type: :request do
  describe 'POST /import' do
    subject do
      post import_products_url, params: { csv: fixture_file_upload(csv, 'text/csv') }
      response
    end

    describe 'success' do
      context 'when CSV contains proper values' do
        let(:csv) { 'correct.csv' }

        it 'responds with 200 and created records' do
          expect(subject.status).to eq 200
          expect(JSON.parse(subject.body)).to satisfy { _1.is_a?(Array) && _1.size == 8 }
        end
      end
    end

    describe 'failure' do
      context 'when CSV contains incorrect values' do
        let(:csv) { 'incorrect.csv' }

        it 'responds with 400 and an error message' do
          expect(JSON.parse(subject.body)).to match hash_including(
            'error' => 'Validation of Product failed. Default price is not a number',
            'error_details' => hash_including(
              'default_price' => nil,
              'name' => 'Cabbage Patch Hat',
              'stock' => 254
            )
          )
        end
      end

      context 'when CSV format is bad'

      context 'when CSV is empty'
    end
  end
end
