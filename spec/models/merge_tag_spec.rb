require 'rails_helper'

RSpec.describe MergeTag, type: :model do
  let(:mt) { create(:merge_tag) }

  describe '.create' do
    it 'creates MergeTag record' do
      expect { mt }.to change { MergeTag.count }.from(0).to(1)
    end
  end

  describe '#valid?' do
    let(:mt) { build(:merge_tag) }

    subject { mt.valid? }

    it { is_expected.to be(true) }

    context 'without start_offset' do
      before { mt.start_offset = nil }

      it { is_expected.to be(false) }
    end

    context 'without end_offset' do
      before { mt.end_offset = nil }

      it { is_expected.to be(false) }
    end

    context 'continue tags' do
      let!(:mt2) { create(:merge_tag, :approved, start_offset: 5, end_offset: 10) }
      let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 1, end_offset: 6) }

      it { is_expected.to be(true) }
    end

    context 'with overwraps on the same paragraph' do
      let!(:mt2) { create(:merge_tag, :approved, start_offset: 5, end_offset: 10) }

      context 'when overwraps with not approved tag' do
        let!(:mt2) { create(:merge_tag, start_offset: 5, end_offset: 10) }
        context 'with approved' do
          let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 8, end_offset: 13) }
          it { is_expected.to be(true) }
        end

        context 'with approved' do
          let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 2, end_offset: 8) }
          it { is_expected.to be(true) }
        end
      end

      context 'with overwraps on start offset' do
        let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 8, end_offset: 13) }
        it { is_expected.to be(false) }

        context 'when not approved' do
          let(:mt) { build(:merge_tag, paragraph: mt2.paragraph, start_offset: 8, end_offset: 13) }
          it { is_expected.to be(true) }
        end
      end

      context 'with overwraps on end offset' do
        let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 2, end_offset: 8) }
        it { is_expected.to be(false) }

        context 'when not approved' do
          let(:mt) { build(:merge_tag, paragraph: mt2.paragraph, start_offset: 2, end_offset: 8) }
          it { is_expected.to be(true) }
        end
      end

      context 'with same start offset' do
        let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 5, end_offset: 8) }

        it { is_expected.to be(true) }
      end

      context 'with same end offset' do
        let(:mt) { build(:merge_tag, :approved, paragraph: mt2.paragraph, start_offset: 8, end_offset: 10) }

        it { is_expected.to be(true) }
      end
    end
  end

  describe '#merge_value' do
    it 'belongs to a MergeValue' do
      expect(mt.merge_value).to be_a(MergeValue)
    end
  end

  describe '#paragraph' do
    it 'belongs to a Paragraph' do
      expect(mt.paragraph).to be_a(Paragraph)
    end
  end

  describe '#start_offset' do
    it 'returns start offset' do
      expect(mt.start_offset).to eq(5)
    end
  end

  describe '#end_offset' do
    it 'returns end offset' do
      expect(mt.end_offset).to eq(10)
    end
  end

  describe '#status' do
    subject { mt.status }

    context 'when not_approved' do
      it { is_expected.to eq 'not_approved' }
    end

    context 'when approved' do
      let(:mt) { create(:merge_tag, :approved) }

      it { is_expected.to eq 'approved' }
    end

    context 'when deleted' do
      let(:mt) { create(:merge_tag, :deleted) }

      it { is_expected.to eq 'deleted' }
    end
  end

  describe '#not_approved?' do
    it 'returns true by default' do
      expect(mt.not_approved?).to be true
    end
  end

  describe '#determined?' do
    subject { mt.determined? }

    context 'when not_approved' do
      it { is_expected.to be false }
    end

    context 'when approved' do
      let(:mt) { create(:merge_tag, :approved) }

      it { is_expected.to be true }
    end

    context 'when deleted' do
      let(:mt) { create(:merge_tag, :deleted) }

      it { is_expected.to be true }
    end
  end
end
