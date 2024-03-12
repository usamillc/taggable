require 'rails_helper'

RSpec.describe EntityLink, type: :model do
  describe '.create' do
    let(:el) { create(:entity_link) }

    it 'creates EntityLink record' do
      expect { el }.to change { EntityLink.count }.from(0).to(1)
    end

    it 'creates EntityLink with default values' do
      expect(el.suggested?).to be(true)
      expect(el.match).to be(false)
      expect(el.later_name).to be(false)
      expect(el.part_of).to be(false)
      expect(el.derivation_of).to be(false)
    end
  end

  describe '#valid?' do
    let(:el) { build(:entity_link) }

    subject { el.valid? }

    it { is_expected.to be(true) }

    context 'without title' do
      before { el.title = nil }
      it { is_expected.to be(false) }
    end

    context 'with empty title' do
      before { el.title = '' }
      it { is_expected.to be(false) }
    end

    context 'without pageid' do
      before { el.pageid = nil }
      it { is_expected.to be(true) }
    end

    context 'with match true' do
      before { el.match = true }
      it { is_expected.to be(true) }

      context 'with later name true' do
        before { el.later_name = true }
        it { is_expected.to be(false) }
      end

      context 'with part of true' do
        before { el.part_of = true }
        it { is_expected.to be(false) }
      end

      context 'with derivation_of of true' do
        before { el.derivation_of = true }
        it { is_expected.to be(false) }
      end
    end

    context 'when approved' do
      before { el.status = :approved }

      context 'without any link type' do
        it { is_expected.to be(false) }
      end

      context 'with link type' do
        before { el.match = true }
        it { is_expected.to be(true) }
      end
    end
  end
end
