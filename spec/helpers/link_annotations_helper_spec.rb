require 'rails_helper'

RSpec.describe LinkAnnotationsHelper, type: :helper do
  describe '.match' do
    let(:s) { "カザフスタン" }
    let(:trie) { LinkAnnotationsHelper::Trie.new }

    subject { trie.match(s) }

    it { is_expected.to match_array([]) }

    context 'with nodes' do
      before do
        trie.add('カザフスタン', :k)
        trie.add('カザフスタンの料理', :r)
        trie.add('湖', :m)
        trie.add('スウェーデン', :s)
      end

      it { is_expected.to match_array([:k]) }

      context 'when partial match' do
        let(:s) { 'カザフスタン共和国' }

        it { is_expected.to match_array([:k]) }
      end

      context 'when partial match 2' do
        let(:s) { 'カザフスタンの首長' }

        it { is_expected.to match_array([:k]) }
      end

      context 'when match starts in middle' do
        let(:s) { 'バイカル湖' }

        it { is_expected.to match_array([:m]) }
      end
    end
  end
end
