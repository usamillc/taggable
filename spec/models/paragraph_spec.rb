require 'rails_helper'

RSpec.describe Paragraph, type: :model do
  describe '#match' do
    let(:p) do
      Paragraph.create(
        body: 'アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ',
        no_tag: 'アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ'
      )
    end
    let(:orig_text) { "\n            アメリカ" }

    it 'finds correspond offset' do
      expect(p.match(orig_text, 13, 17)).to eq [0, 4]
    end

    context 'with repeated characters at start' do
      let(:p) do
        Paragraph.create(
          body: "<p>戸来岳（へらいだけ）は、青森県新郷村と十和田市の境にある山である。最高峰の三ツ岳（みつだけ 1,159m[1][2]）と大駒ヶ岳（おおこまがたけ 1,144m)を総称して戸来岳と言う。一部のガイドブックはこれに大文字山（だいもんじやま 1,014m）を加えている。三ツ岳は、十和田湖方面から見ると、正三角形のように見えるが、十和田市方面から見ると、ピークが三つ（三ツ岳、大駒ヶ岳、大文字山）に見える。これが三ツ岳の山名の由来とみられる。</p>",
          no_tag: "戸来岳（へらいだけ）は、青森県新郷村と十和田市の境にある山である。最高峰の三ツ岳（みつだけ 1,159m[1][2]）と大駒ヶ岳（おおこまがたけ 1,144m)を総称して戸来岳と言う。一部のガイドブックはこれに大文字山（だいもんじやま 1,014m）を加えている。三ツ岳は、十和田湖方面から見ると、正三角形のように見えるが、十和田市方面から見ると、ピークが三つ（三ツ岳、大駒ヶ岳、大文字山）に見える。これが三ツ岳の山名の由来とみられる。"
        )
      end
      let(:orig_text) { "戸来岳（へらいだけ）は、青森県新郷村と十和田市の境にある山である。最高峰の三ツ岳（みつだけ 1,159m[1][2]）と大駒ヶ岳（おおこまがたけ" }

      it 'finds correspond offset' do
        expect(p.match(orig_text, 65, 72)).to eq [65, 72]
      end
    end

    context 'with repeated characters at end' do
      let(:p) do
        Paragraph.create(
          body: "東側は石巻湾越しに牡鹿半島が望め、その向こうに金華山山頂も遠望できる。",
          no_tag: "東側は石巻湾越しに牡鹿半島が望め、その向こうに金華山山頂も遠望できる。"
        )
      end
      let(:orig_text) { "東側は石巻湾越しに牡鹿半島が望め、その向こうに金華山" }

      it 'finds correspond offset' do
        expect(p.match(orig_text, 23, 26)).to eq [23, 26]
      end
    end
  end
end
