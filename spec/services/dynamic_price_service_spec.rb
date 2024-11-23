require 'rails_helper'

describe DynamicPriceService do
  let(:instance) { described_class.new(product) }

  describe '#initialize' do
    let(:product) { build(:product) }
    let(:competing_price) { 500 }

    it 'assigns the provided product and its competing price to instance variables' do
      expect(product).to receive(:competing_price).and_return competing_price
      expect(instance.instance_variable_get(:@product)).to eq product
      expect(instance.instance_variable_get(:@competing_price)).to eq competing_price
    end
  end

  describe '#calculate' do
    subject { instance.calculate }

    shared_examples 'correct calculation' do |value_description, value, product_attrs = []|
      let(:product) { build(:product, *product_attrs) }

      it "returns the #{value_description}" do
        expect(subject).to eq value
      end
    end

    context 'when the competing price IS NOT available' do
      context 'and the dynamic price is lower than the default price' do
        it_behaves_like 'correct calculation', 'default price', 600, [:very_high_stock]
      end

      context 'and the dynamic price is equal to the default price' do
        it_behaves_like 'correct calculation', 'default price', 600, %i[high_stock low_demand]
      end

      context 'and the dynamic price is between the default_price and the price cap' do
        it_behaves_like 'correct calculation', 'dynamic price', 660, [:medium_stock]
      end

      context 'and the dynamic price is equal to the price cap' do
        it_behaves_like 'correct calculation', 'price cap', 780, %i[low_stock medium_demand]
      end

      context 'and the dynamic price is higher than the price cap' do
        it_behaves_like 'correct calculation', 'price cap', 780, %i[low_stock high_demand]
      end
    end

    context 'when the competing price IS available' do
      context 'and is BETWEEN the default price and the price cap' do
        before { allow(product).to receive(:competing_price).and_return 700 }

        context 'and is higher than the dynamic price' do
          context 'when the dynamic price is between the default price and the price cap' do
            it_behaves_like 'correct calculation', 'dynamic price', 660, [:medium_demand]
          end

          context 'when the dynamic price is lower than the default price' do
            it_behaves_like 'correct calculation', 'default price', 600, [:very_high_stock]
          end

          context 'when the dynamic price is equal to the default price' do
            it_behaves_like 'correct calculation', 'default price', 600
          end
        end

        context 'and is lower than the dynamic price' do
          context 'when the dynamic price is lower than the price cap' do
            it_behaves_like 'correct calculation', 'competing price', 700, %i[medium_stock medium_demand]
          end

          context 'when the dynamic price is higher than the price cap' do
            it_behaves_like 'correct calculation', 'competing price', 700, %i[low_stock high_demand]
          end

          context 'when the dynamic price is equal to the price cap' do
            it_behaves_like 'correct calculation', 'competing price', 700, %i[low_stock medium_demand]
          end
        end
      end

      context 'and is HIGHER than the PRICE CAP' do
        context 'and is higher than the dynamic price' do
          before { allow(product).to receive(:competing_price).and_return 850 }

          context 'when the dynamic price is between the default price and the price cap' do
            it_behaves_like 'correct calculation', 'dynamic price', 720, %i[low_stock low_demand]
          end

          context 'when the dynamic price is higher than the price cap' do
            it_behaves_like 'correct calculation', 'price cap', 780, %i[low_stock high_demand]
          end

          context 'when the dynamic price is lower than the default price' do
            it_behaves_like 'correct calculation', 'default price', 600, %i[very_high_stock low_demand]
          end

          context 'when the dynamic price is equal to the default price' do
            it_behaves_like 'correct calculation', 'default price', 600, %i[high_stock low_demand]
          end

          context 'when the dynamic price is equal to the price cap' do
            it_behaves_like 'correct calculation', 'price cap', 780, %i[low_stock medium_demand]
          end
        end

        context 'and is lower than the dynamic price' do
          before { allow(product).to receive(:competing_price).and_return 820 }

          it_behaves_like 'correct calculation', 'price cap', 780, %i[low_stock high_demand]
        end
      end

      context 'and it is EQUAL to the PRICE CAP' do
        before { allow(product).to receive(:competing_price).and_return 780 }

        context 'when the dynamic price is between the default price and the price cap' do
          it_behaves_like 'correct calculation', 'dynamic price', 660, %i[medium_stock low_demand]
        end

        context 'when the dynamic price is equal to the price cap' do
          it_behaves_like 'correct calculation', 'price cap', 780, %i[medium_stock high_demand]
        end

        context 'when the dynamic price is higher than the price cap' do
          it_behaves_like 'correct calculation', 'price cap', 780, %i[low_stock high_demand]
        end

        context 'when the dynamic price is lower than the default price' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[very_high_stock low_demand]
        end

        context 'when the dynamic price is equal to the default price' do
          it_behaves_like 'correct calculation', 'default price', 600
        end
      end

      context 'and is LOWER than the DEFAULT PRICE' do
        before { allow(product).to receive(:competing_price).and_return 500 }

        context 'and the dynamic price is between the default price and the price cap' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[very_high_stock high_demand]
        end

        context 'when the dynamic price is equal to the price cap' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[low_stock medium_demand]
        end

        context 'and the dynamic price is higher than the price cap' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[low_stock high_demand]
        end

        context 'when the dynamic price is equal to the default price' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[very_high_stock medium_demand]
        end

        context 'and the dynamic price is lower than the default price' do
          context 'and higher than the competing price' do
            it_behaves_like 'correct calculation', 'default price', 600, [:very_high_stock]
          end

          context 'and lower than the competing price' do
            before { allow(product).to receive(:competing_price).and_return 550 }

            it_behaves_like 'correct calculation', 'default price', 600, [:very_high_stock]
          end
        end
      end

      context 'and it is EQUAL to the DEFAULT PRICE' do
        before { allow(product).to receive(:competing_price).and_return 600 }

        context 'when the dynamic price is lower than the default price' do
          it_behaves_like 'correct calculation', 'default price', 600, [:very_high_stock]
        end

        context 'when the dynamic price is equal to the default price' do
          it_behaves_like 'correct calculation', 'default price', 600
        end

        context 'when the dynamic price is between the default price and the price cap' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[high_stock medium_demand]
        end

        context 'when the dynamic price is equal to the price cap' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[medium_stock high_demand]
        end

        context 'when the dynamic price is higher than the price cap' do
          it_behaves_like 'correct calculation', 'default price', 600, %i[low_stock high_demand]
        end
      end
    end
  end
end
