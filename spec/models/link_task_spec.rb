require 'rails_helper'

RSpec.describe LinkTask, type: :model do
  let(:task) { create(:link_task, :with_annotations) }

  describe '#link_annotations' do
    it 'returns associated link annotations' do
      expect(task.link_annotations.count).to eq(10)
    end

    it 'should be ordered by merge tag paragraph id' do
      paragraph_ids = task.link_annotations.map(&:merge_tag).map(&:paragraph_id)
      expect(paragraph_ids).to eq(paragraph_ids.sort())
    end
  end

  describe '#incomplete_annotations' do
    it 'returns incomplete link annotations' do
      expect(task.incomplete_annotations.count).to eq(5)
    end
  end

  describe '#completable?' do
    context 'with incomplete link annotations' do
      it { expect(task).not_to be_completable }
    end

    context 'with completed link annotations' do
      let(:task) { create(:link_task, :with_completed_annotations) }

      it { expect(task).to be_completable }
    end
  end
end
