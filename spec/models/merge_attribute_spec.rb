require 'rails_helper'

RSpec.describe MergeAttribute, type: :model do
  let(:ma) { create(:merge_attribute) }

  describe '.create' do
    it 'creates MergeAttribute record' do
      expect { ma }.to change { MergeAttribute.count }.from(0).to(1)
    end
  end

  describe '#merge_task' do
    it 'belongs to a MergeTask' do
      expect(ma.merge_task).to be_a(MergeTask)
    end
  end

  describe '#merge_tags' do
    let!(:mv) { create(:merge_value, merge_attribute: ma) }
    let!(:mt) { create(:merge_tag, merge_value: mv) }

    it 'returns associated merge tags' do
      expect(ma.merge_tags).to match_array([mt])
    end
  end

  describe '#name' do
    it 'returns name' do
      expect(ma.name).to eq('kana')
    end
  end

  describe '#tag' do
    it 'returns uppercased name' do
      expect(ma.tag).to eq(ma.name.upcase)
    end
  end

  describe '#screenname' do
    it 'returns screenname' do
      expect(ma.screenname).to eq('ふりがな')
    end
  end

  describe '#completed?' do
    it 'returns false by default' do
      expect(ma.completed?).to be(false)
    end

    context 'when completed' do
      let(:ma) { create(:merge_attribute, :completed) }

      it 'returns true' do
        expect(ma.completed?).to be(true)
      end
    end
  end

  describe '#completable?' do
    subject { ma.completable? }

    context 'with non approved merge tags' do
      let!(:mv) { create(:merge_value, merge_attribute: ma) }
      let!(:mt) { create(:merge_tag, merge_value: mv) }

      it { is_expected.to be false }
    end

    context 'with approved merge tags' do
      let!(:mv) { create(:merge_value, merge_attribute: ma) }
      let!(:mt) { create(:merge_tag, :approved, merge_value: mv) }

      it { is_expected.to be true }
    end
  end
end
