require 'rails_helper'

shared_examples 'a merge attribute builder' do
  it 'creates merge attributes' do
    expect { subject }.to change(MergeAttribute, :count).by(1)
    expect(MergeAttribute.last.merge_task).to eq(MergeTask.last)
  end

  context 'with deleted annotation attribute' do
    let!(:deleted_attr) { create(:annotation_attribute, :deleted, category: p.category) }

    it 'creates merge attributes only for non-deleted annotation attributes' do
      expect { subject }.to change(MergeAttribute, :count).by(1)
      expect(MergeAttribute.last.merge_task).to eq(MergeTask.last)
    end
  end
end

shared_examples 'a merge value builder' do
  it 'creates merge values' do
    expect { subject }.to change(MergeValue, :count).by(1)
    expect(MergeValue.last.merge_attribute).to eq(MergeAttribute.last)
  end
end

RSpec.describe Page, type: :model do
  let!(:tp) { create(:task_paragraph) }
  let(:p) { tp.task.page }

  describe '#prepare_merge!' do
    let!(:attr) { create(:annotation_attribute, category: p.category) }
    let!(:a) { create(:annotation, annotation_attribute: attr, task_paragraph: tp) }

    subject { p.prepare_merge! }

    it 'creates merge tasks' do
      expect { subject }.to change(MergeTask, :count).by(1)
      expect(MergeTask.last.page).to eq(p)
    end

    it_behaves_like 'a merge attribute builder'
    it_behaves_like 'a merge value builder'

    context 'with empty annotation value' do
      let!(:a) { create(:annotation, annotation_attribute: attr, task_paragraph: tp, value: "") }

      it 'should not create a merge value' do
        expect { subject }.not_to change(MergeValue, :count)
      end
    end

    it 'creates a merge tag' do
      expect { subject }.to change(MergeTag, :count).by(1)
      expect(MergeTag.last.merge_value).to eq(MergeValue.last)
      expect(MergeTag.last.paragraph).to eq(tp.paragraph)
      expect(MergeTag.last.approved?).to be(true)
    end

    context 'with same annotation value' do
      let!(:a2) { create(:annotation, annotation_attribute: attr, task_paragraph: tp) }

      it 'only create one merge value' do
        expect { subject }.to change(MergeValue, :count).by(1)
      end

      it 'creates two merge tags' do
        expect { subject }.to change(MergeTag, :count).by(2)
      end
    end

    context 'with annotation overwraps' do
      let!(:a) { create(:annotation, annotation_attribute: attr, task_paragraph: tp, start_offset: 5) }
      let!(:a2) { create(:annotation, annotation_attribute: attr, task_paragraph: tp, start_offset: 3) }

      it 'creates two non-approved merge tags' do
        expect { subject }.to change(MergeTag, :count).by(2)
        expect(MergeTag.last.not_approved?).to be(true)
      end
    end

    context 'with deleted annotation' do
      let!(:a) { create(:annotation, :deleted, annotation_attribute: attr) }
      it 'does not create merge value and merge tag' do
        expect { subject }.not_to change(MergeValue, :count)
        expect { subject }.not_to change(MergeTag, :count)
      end
    end

    context 'with other page' do
      let!(:p2) { create(:page, category: p.category) }
      let!(:t2) { create(:task, page: p2) }
      let!(:tp2) { create(:task_paragraph, task: t2) }
      let!(:a2) { create(:annotation, annotation_attribute: attr, task_paragraph: tp2) }

      it_behaves_like 'a merge attribute builder'
      it_behaves_like 'a merge value builder'

      it 'creates a merge tag' do
        expect { subject }.to change(MergeTag, :count).by(1)
      end
    end
  end
end
