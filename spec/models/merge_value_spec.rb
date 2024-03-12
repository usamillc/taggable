require 'rails_helper'

RSpec.describe MergeValue, type: :model do
  let(:mv) { create(:merge_value) }

  describe '.create' do
    it 'creates MergeValue record' do
      expect { mv }.to change { MergeValue.count }.from(0).to(1)
    end
  end

  describe '#merge_attribute' do
    it 'belongs to a MergeAttribute' do
      expect(mv.merge_attribute).to be_a(MergeAttribute)
    end
  end

  describe '#merge_task' do
    it 'returns belonging MergeTask' do
      expect(mv.merge_task).to be_a(MergeTask)
    end
  end

  describe '#merge_tags' do
    let!(:mt) { create(:merge_tag, merge_value: mv) }
    it 'returns associated merge tags' do
      expect(mv.merge_tags).to match_array([mt])
    end

    context 'with deleted merge tags' do
      let!(:mt2) { create(:merge_tag, :deleted, merge_value: mv) }
      it 'returns only non deleted merge tags' do
        expect(mv.merge_tags).to match_array([mt])
      end
    end
  end

  describe '#value' do
    it 'returns value' do
      expect(mv.value).to eq('アメリカ')
    end
  end

  describe '#n_tags_left' do
    subject { mv.n_tags_left }

    it { is_expected.to eq 0 }

    context 'with non approved merge tags' do
      before do
        5.times { create(:merge_tag, merge_value: mv) }
      end

      it { is_expected.to eq 5 }
    end

    context 'with approved and deleted merge tags' do
      before do
        create(:merge_tag, :approved, merge_value: mv)
        create(:merge_tag, :deleted, merge_value: mv)
      end

      it { is_expected.to eq 0 }
    end
  end

  describe '#increment_count!' do
    subject { mv.increment_count! }

    it { expect { subject }.to change(mv, :annotator_count).by(1) }
  end
end
