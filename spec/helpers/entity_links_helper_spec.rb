require 'rails_helper'

RSpec.describe EntityLinksHelper, type: :helper do
  describe '.mediawiki_url_prefix' do
    subject { helper.mediawiki_url_prefix(version) }

    context 'with version 20210820' do
      let(:version) { "20210820" }

      it { is_expected.to eq('http://wikipedia-ja-20210820.kanaf.info/wiki/') }
    end

    context 'with other versions' do
      let(:version) { nil }

      it { is_expected.to eq('https://ja.mediawiki.usami.llc/wiki/') }
    end
  end

  describe '.parse_title' do
    let(:url) { "https://ja.mediawiki.usami.llc/wiki/カザフスタン" }
    let(:version) { nil }

    subject { helper.parse_title(url, version) }

    it { is_expected.to eq('カザフスタン') }

    context 'with spaces in title' do
      let(:url) { "https://ja.mediawiki.usami.llc/wiki/ニューアーク_(ニュージャージー州)" }

      it { is_expected.to eq('ニューアーク (ニュージャージー州)') }
    end

    context 'with % encoded title' do
      let(:url) { "https://ja.mediawiki.usami.llc/wiki/%E3%82%AB%E3%82%B6%E3%83%95%E3%82%B9%E3%82%BF%E3%83%B3" }

      it { is_expected.to eq('カザフスタン') }
    end
  end
end
