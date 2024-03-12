require 'rails_helper'

RSpec.describe AnnotationAttribute, type: :model do
  let!(:cat1) { create(:category) }

  describe '.swap_ord' do
    let!(:a) { create(:annotation_attribute, category: cat1, ord: 1) }
    let!(:b) { create(:annotation_attribute, category: cat1, ord: 2) }

    it "swaps two annotation attributes' ord" do
      expect { AnnotationAttribute.swap(a, b) }
        .to change(a, :ord).from(1).to(2)
        .and change(b, :ord).from(2).to(1)
    end
  end

  describe '.find_upper_ord_one' do
    let!(:a) { create(:annotation_attribute, category: cat1, ord: 1) }
    let!(:b) { create(:annotation_attribute, category: cat1, ord: 2) }
    let!(:c) { create(:annotation_attribute, category: cat1, ord: 4) }

    it 'finds the max ord annotation attribute not exceed the given ord' do
      expect(AnnotationAttribute.find_upper_ord_one(b)).to eq a
      expect(AnnotationAttribute.find_upper_ord_one(c)).to eq b
    end

    context 'when there is no matching annotation attribute' do
      it 'raises RecordNotFound' do
        expect { AnnotationAttribute.find_upper_ord_one(a) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with annotation attribuets in other categories' do
      let!(:cat2) { create(:category) }
      let!(:d) { create(:annotation_attribute, category: cat2, ord: 3) }

      it 'only returns annotation attribute with the same category' do
        expect(AnnotationAttribute.find_upper_ord_one(c)).to eq b
        expect { AnnotationAttribute.find_upper_ord_one(d) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.find_lower_ord_one' do
    let!(:a) { create(:annotation_attribute, category: cat1, ord: 1) }
    let!(:b) { create(:annotation_attribute, category: cat1, ord: 2) }
    let!(:c) { create(:annotation_attribute, category: cat1, ord: 4) }

    it 'finds the min ord annotation attribute exceeds the given ord' do
      expect(AnnotationAttribute.find_lower_ord_one(a)).to eq b
      expect(AnnotationAttribute.find_lower_ord_one(b)).to eq c
    end

    context 'when there is no matching annotation attribute' do
      it 'raises RecordNotFound' do
        expect { AnnotationAttribute.find_lower_ord_one(c) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with annotation attribuets in other categories' do
      let!(:cat2) { create(:category) }
      let!(:d) { create(:annotation_attribute, category: cat2, ord: 3) }

      it 'only returns annotation attribute with the same category' do
        expect(AnnotationAttribute.find_lower_ord_one(b)).to eq c
        expect { AnnotationAttribute.find_lower_ord_one(d) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
