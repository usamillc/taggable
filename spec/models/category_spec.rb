require 'rails_helper'

RSpec.describe Category, type: :model do
  let!(:c) { create(:category) }

  describe '#annotation_attributes' do
    let!(:a) { create(:annotation_attribute, category: c) }

    subject { c.annotation_attributes }

    it 'returns associated annotation attributes' do
      expect(subject).to match_array [a]
    end

    context 'with deleted annotation attribute' do
      let!(:b) { create(:annotation_attribute, :deleted, category: c) }

      it 'should not return deleted annotation attribute' do
        expect(subject).to match_array [a]
      end
    end
  end

  describe '#prepare_merge!' do
    subject { c.prepare_merge! }

    context 'without pages' do
      it 'does nothing' do
        expect { subject }.not_to change(MergeTask, :count)
      end
    end

    context 'with pages' do
      let!(:p) { create(:page, category: c) }

      context 'with some non-completed tasks' do
        let!(:t) { create(:task, page: p) }

        it 'does nothing' do
          expect { subject }.not_to change(MergeTask, :count)
        end
      end

      context 'with completed tasks' do
        let!(:t) { create(:task, :completed, page: p) }

        it 'creates MergeTask' do
          expect { subject }.to change(MergeTask, :count).by(1)
        end

        context 'when MergeTask has been created already' do
          let!(:m) { create(:merge_task, page: p) }

          it 'does not create MergeTask' do
            expect { subject }.not_to change(MergeTask, :count)
          end
        end
      end
    end
  end
end
