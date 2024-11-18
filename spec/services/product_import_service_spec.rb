require 'rails_helper'

describe ProductImportService do
  describe '#process' do
    after { csv.close }

    subject { described_class.new(csv).process }

    context 'when CSV file contains correct data' do
      let(:csv) { File.open('spec/fixtures/files/correct.csv') }

      it 'creates new categories and products' do
        expect { subject }.to \
          change { Product.count }.by(5).and \
          change { Category.count }.by 3
      end

      it 'returns created records' do
        expect(subject).to satisfy { _1.is_a?(Set) && _1.size == 8 }
      end
    end

    context 'when CSV file contains incorrect data' do
      let(:csv) { File.open('spec/fixtures/files/incorrect.csv') }

      it 'raises an error and does not create records' do
        expect { subject }.to \
          raise_error(Mongoid::Errors::Validations, /Validation of Product failed/).and \
          not_change(Product, :count).and \
          not_change(Category, :count)
      end
    end
  end
end
