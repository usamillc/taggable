require 'rails_helper'

RSpec.describe AnnotatedEntityLink, type: :model do
  let(:ael) { create(:annotated_entity_link, status) }
  let(:status) { nil }

  describe '.create_by_consensus!' do
    let(:lma) { create(:link_merge_annotation) }
    let(:el) { create(:entity_link, :match) }
    let(:els) { [ el ] }
    let(:ael) { AnnotatedEntityLink.create_by_consensus!(lma, els) }

    it { expect { AnnotatedEntityLink.create_by_consensus!(lma, [el]) }.to change(AnnotatedEntityLink, :count).by(1) }

    it 'copies entity link fields' do
      expect(ael.title).to eq(el.title)
      expect(ael.pageid).to eq(el.pageid)
      expect(ael.first_sentence).to eq(el.first_sentence)
    end

    it 'counts link type annotations' do
      expect(ael.match_count).to eq(1)
    end

    context 'with consensus' do
      let(:els) { [ el1, el2 ] }

      [:match, :later_name, :part_of, :derivation_of].each do |link_type|
        context "when #{link_type}" do
          let(:el1) { create(:entity_link, link_type) }
          let(:el2) { create(:entity_link, link_type) }

          it { expect(ael.send("#{link_type}?")).to be true }
        end
      end
    end
  end

  describe '#countup_annotation' do
    [:match, :later_name, :part_of, :derivation_of].each do |link_type|
      context "when passed #{link_type} entity link" do
        let(:e) { create(:entity_link, link_type) }

        it { expect { ael.countup_annotation(e) }.to change(ael, "#{link_type}_count").by(1) }
      end
    end
  end

  describe '#valid?' do
    let(:ale) { build(:annotated_entity_link) }

    subject { ael.valid? }

    it { is_expected.to be(true) }

    context 'without title' do
      before { ael.title = nil }

      it { is_expected.to be(false) }
    end

    context 'with empty title' do
      before { ael.title = '' }

      it { is_expected.to be(false) }
    end

    context 'without pageid' do
      before { ael.pageid = nil }

      it { is_expected.to be(true) }
    end

    context 'with match true' do
      before { ael.match = true }

      it { is_expected.to be(true) }

      context 'with later name true' do
        before { ael.later_name = true }

        it { is_expected.to be(false) }
      end

      context 'with part of true' do
        before { ael.part_of = true }

        it { is_expected.to be(false) }
      end

      context 'with derivation_of of true' do
        before { ael.derivation_of = true }

        it { is_expected.to be(false) }
      end
    end

    context 'when approved' do
      let(:status) { :approved }

      context 'without any link type' do
        before { ael.match = false }

        it { is_expected.to be(false) }
      end

      context 'with link type' do
        before { ael.match = true }

        it { is_expected.to be(true) }
      end
    end
  end
end
