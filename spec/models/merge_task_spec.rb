require 'rails_helper'

RSpec.describe MergeTask, type: :model do
  let(:m) { create(:merge_task) }
  let(:a) { create(:annotator) }

  describe '.create' do
    it 'creates MergeTask record' do
      expect { m }.to change { MergeTask.count }.from(0).to(1)
    end
  end

  describe '#page' do
    it 'returns belonging page' do
      expect(m.page).to be_a(Page)
    end
  end

  describe '#last_changed_annotator' do
    context 'without associated annotator' do
      it 'retuns nil' do
        expect(m.last_changed_annotator).to be_nil
      end
    end

    context 'with associated annotator' do
      let(:m) { create(:merge_task, :with_annotator) }

      it 'returns last changed annotator' do
        expect(m.last_changed_annotator).to be_an(Annotator)
      end
    end
  end

  describe '#category' do
    it 'returns category which associated page belongs' do
      expect(m.category).to be_a(Category)
    end
  end

  describe '#merge_attributes' do
    let!(:ma) { create(:merge_attribute, merge_task: m) }

    it 'returns associated merge attributes' do
      expect(m.merge_attributes).to match_array([ma])
    end

    context 'with many merge attributes' do
      before do
        as = []
        10.times { as << create(:merge_attribute, merge_task: m) }
        ids = as.map(&:id).shuffle
        as.each_with_index do |ma, i|
          ma.id = ids[i] + 10
          ma.save
        end
      end

      it 'returns merge attributes in order' do
        expect(m.merge_attributes).to eq(MergeAttribute.order(id: :asc))
      end
    end
  end

  describe '#merge_tags' do
    let!(:ma) { create(:merge_attribute, merge_task: m) }
    let!(:mv) { create(:merge_value, merge_attribute: ma) }
    let!(:mt) { create(:merge_tag, merge_value: mv) }

    it 'returns all merge tags' do
      expect(m.merge_tags).to match_array([mt])
    end
  end

  describe '#status' do
    subject { m.status }

    context 'by default' do
      it { is_expected.to eq 'not_started' }
    end

    context 'when in progress' do
      let(:m) { create(:merge_task, :in_progress) }

      it { is_expected.to eq 'in_progress' }
    end

    context 'when completed' do
      let(:m) { create(:merge_task, :completed) }

      it { is_expected.to eq 'completed' }
    end
  end

  describe '#start!' do
    context 'when not started' do
      it 'changes status to in progress' do
        expect { m.start!(a) }.to change(m, :status).from('not_started').to('in_progress')
      end

      it 'assigns last changed annotator' do
        expect { m.start!(a) }.to change(m, :last_changed_annotator).to(a)
      end
    end

    context 'when completed' do
      let(:m) { create(:merge_task, :completed) }

      it 'changes status back to in progress' do
        expect { m.start!(a) }.to change(m, :status).from('completed').to('in_progress')
      end
    end
  end

  describe '#finish!' do
    context 'when in progress' do
      let(:m) { create(:merge_task, :in_progress) }

      it 'changes status to completed' do
        expect { m.finish!(a) }.to change(m, :status).from('in_progress').to('completed')
      end

      it 'assigns last changed annotator' do
        expect { m.finish!(a) }.to change(m, :last_changed_annotator).to(a)
      end
    end
  end

  describe '#completable?' do
    subject { m.completable? }

    context 'with non completed merge attributes' do
      let!(:ma) { create(:merge_attribute, merge_task: m) }

      it { is_expected.to be(false) }
    end

    context 'with completed merge attributes' do
      let!(:ma) { create(:merge_attribute, :completed, merge_task: m) }

      it { is_expected.to be(true) }
    end
  end
end
