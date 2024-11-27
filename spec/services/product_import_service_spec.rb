require 'rails_helper'

describe ProductImportService do
  describe '#process' do
    subject { described_class.new(csv).process }

    shared_examples 'successful import' do
      it 'creates new records in the database' do
        expect { subject }.to change { Product.count }.by(1).and \
                              change { Category.count }.by 1
      end
    end

    shared_examples 'product validation error' do
      it 'raises an error and does not create records' do
        expect { subject }.to raise_error(Mongoid::Errors::Validations, /Validation of Product failed/).and \
                              not_change { Product.count }.and \
                              not_change { Category.count }
      end
    end

    shared_examples 'invalid input' do |path:|
      let(:csv) { File.open(path) }

      it 'raises CSV::MalformedCSVError' do
        expect { subject }.to raise_error CSV::MalformedCSVError
      end
    end

    context 'when CSV file has valid data' do
      let(:csv) { File.open('spec/fixtures/files/correct.csv') }

      it_behaves_like 'successful import'

      context 'when the category already exists in the database' do
        let!(:category) { create(:category, name: 'Footwear') }

        context 'when product in this category also exists' do
          let!(:product) { create(:product, name: 'MC Hammer Pants', category: category) }
          it_behaves_like 'product validation error'
        end

        context 'when product in this category does not exist' do
          it 'successfully imports data into the existing category' do
            expect { subject }.to change { Product.count }.by(1).and \
                                  not_change { Category.count }
          end
        end
      end

      context 'when a product with the same name exists in a different category' do
        let!(:product) { create(:product, name: 'MC Hammer Pants') }
        it_behaves_like 'successful import'
      end
    end

    context 'when CSV file has invalid data' do
      context 'when the file has missing values' do
        let(:csv) { File.open('spec/fixtures/files/incorrect.csv') }
        it_behaves_like 'product validation error'
      end

      context 'when the file has missing header' do
        it_behaves_like 'invalid input', path: 'spec/fixtures/files/no_header.csv'
      end

      context 'when the file has only header' do
        it_behaves_like 'invalid input', path: 'spec/fixtures/files/only_header.csv'
      end

      context 'when the file is empty' do
        it_behaves_like 'invalid input', path: 'spec/fixtures/files/empty.csv'
      end

      context 'when the file is not a valid CSV' do
        it_behaves_like 'invalid input', path: 'spec/fixtures/files/not.csv'
      end
    end
  end
end
