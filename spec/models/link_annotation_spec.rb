require 'rails_helper'

RSpec.describe LinkAnnotation, type: :model do
  describe '#next' do
    let!(:la) { task.link_annotations.first }

    subject { la.next }

    context 'with a next incomplete link annotation' do
      let!(:task) { create(:link_task, :with_annotations) }
      let!(:la2) { task.incomplete_annotations.second }

      it { is_expected.to eq(la2) }
    end

    context 'with no incomplete link annotation' do
      let!(:task) { create(:link_task, :with_completed_annotations) }

      it { is_expected.to be_nil }
    end
  end
end
