require 'rails_helper'

RSpec.describe LinkMergeAnnotation, type: :model do
  describe '#no_link?' do
    subject { lma.no_link? }

    context 'without entity links' do
      let(:lma) { create(:link_merge_annotation) }

      it { is_expected.to be true }
    end

    context 'with rejected links' do
      let(:lma) { create(:link_merge_annotation, :with_rejected_links) }

      it { is_expected.to be true }
    end

    [:with_conflicted_links, :with_approved_and_rejected_links, :with_approved_links].each do |entity_links|
      context entity_links do
        let(:lma) { create(:link_merge_annotation, entity_links) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#valid?' do
    subject { lma.valid? }

    context 'when incomplete' do
      let(:lma) { create(:link_merge_annotation) }

      it { is_expected.to be true }

      context 'with conflicts' do
        let(:lma) { build(:link_merge_annotation, :with_conflicted_links) }

        it { is_expected.to be true }
      end
    end

    context 'when completable' do
      context 'without entity links' do
        let(:lma) { build(:link_merge_annotation, :completed) }

        it { is_expected.to be true }
      end

      [:with_approved_and_rejected_links, :with_approved_links, :with_rejected_links].each do |entity_links|
        context entity_links do
          let(:lma) { build(:link_merge_annotation, :completed, entity_links) }

          it { is_expected.to be true }
        end
      end
    end

    context 'when not completable' do
      context 'with conflicted links' do
        let(:lma) { build(:link_merge_annotation, :completed, :with_conflicted_links) }

        it { is_expected.to be false }
      end
    end
  end
end

