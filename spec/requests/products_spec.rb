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

        it 'creates a new category and a new product' do
          expect { subject }.to change { Category.count }.by(1).and \
                                change { Product.count }.by 1
        end

        it 'responds with 200' do
          expect(subject.status).to eq 200
        end

        context 'when the product already exists in the database' do
          it 'responds with 422 and an error message' do
          end
        end
      end
    end

    describe 'failure' do
      shared_examples 'invalid file import' do |file:, error:|
        let(:csv) { file }

        it "responds with 422 and an error message (#{file})" do
          expect(subject.status).to eq 422
          expect(subject.body).to match error
        end
      end

      context 'when CSV contains incorrect values' do
        it_behaves_like 'invalid file import', file: 'incorrect.csv', error: 'default_price.*is not a number' do
          it 'does not create new records' do
            expect { subject }.to not_change { Category.count }.and \
                                  not_change { Product.count }
          end
        end
      end

      context 'when CSV format is invalid' do
        %w(not.csv empty.csv no_header.csv only_header.csv).each do |file|
          it_behaves_like 'invalid file import', file:, error: 'File must contain (header|records)'
        end
      end

      context 'when something other than a file is submitted' do
        it 'responds with 400 and an error message' do
          post import_products_url, params: { csv: 'abracadabra' }
          expect(response.status).to eq 400
          expect(response.body).to match(/csv.*file is missing/)
        end
      end
    end
  end
end
