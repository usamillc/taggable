require 'rails_helper'

RSpec.describe TaskParagraph, type: :model do
  let!(:t) { create(:task_paragraph) }

  describe '#build_tags' do
    let!(:a1) { create(:annotation, task_paragraph: t, start_offset: 41, value: "アメリカ合衆国") }

    context 'with single annotation' do
      it 'builds tagged html' do
        expect { t.build_tags! }
          .to change(t, :tagged)
          .to "| (1936-10-03) 1936年10月3日（81歳） アメリカ合衆国の旗 #{a1.open_tag}アメリカ合衆国#{a1.close_tag}、ニューヨーク市ブロードウェイ"
      end
    end

    context 'with multiple annotations' do
      let!(:a2) { create(:annotation, task_paragraph: t, start_offset: 15, value: "1936年10月3日") }

      it 'builds multi-tagged html' do
        expect { t.build_tags! }
          .to change(t, :tagged)
          .to "| (1936-10-03) #{a2.open_tag}1936年10月3日#{a2.close_tag}（81歳） アメリカ合衆国の旗 #{a1.open_tag}アメリカ合衆国#{a1.close_tag}、ニューヨーク市ブロードウェイ"
      end
    end

    context 'with multiple annotations for the same word' do
      let(:attribute2) { create(:annotation_attribute, name: 'alias') }
      let!(:a2) { create(:annotation, annotation_attribute: attribute2, task_paragraph: t, start_offset: 41, value: "アメリカ合衆国") }

      it 'builds tagged html with corresponding tag closes' do
        expect { t.build_tags! }
          .to change(t, :tagged)
          .to "| (1936-10-03) 1936年10月3日（81歳） アメリカ合衆国の旗 #{a1.open_tag}#{a2.open_tag}アメリカ合衆国#{a2.close_tag}#{a1.close_tag}、ニューヨーク市ブロードウェイ"
      end
    end

    context 'with nested annotations' do
      let(:att) { create(:annotation_attribute, name: 'place') }
      let!(:a2) {
        create(:annotation, annotation_attribute: att, task_paragraph: t, start_offset: 41,
               value: "アメリカ合衆国、ニューヨーク市ブロードウェイ")
      }

      it 'builds html with nested-tag' do
        expect { t.build_tags! }
          .to change(t, :tagged)
          .to "| (1936-10-03) 1936年10月3日（81歳） アメリカ合衆国の旗 #{a2.open_tag}#{a1.open_tag}アメリカ合衆国#{a1.close_tag}、ニューヨーク市ブロードウェイ#{a2.close_tag}"
      end
    end

    context 'with html tags in body' do
      let!(:t) { create(:task_paragraph, :with_html_tags) }
      let!(:a1) { create(:annotation, task_paragraph: t, start_offset: 39, value: "ミニマル・ミュージック") }

      it 'builds tagged html' do
        expect { t.build_tags! }
          .to change(t, :tagged)
          .to "<p>スティーヴ・ライヒ（Steve Reich, 1936年10月3日 - ）は、#{a1.open_tag}ミニマル・ミュージック#{a1.close_tag}を代表するアメリカの作曲家。母は女優のジューン・キャロル（English版）（旧姓・シルマン）。異父弟に作家のジョナサン・キャロル。</p>"
      end
    end
  end

  describe '#match' do
    let(:p) do
      TaskParagraph.create(
        body: 'アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ',
        no_tag: 'アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ'
      )
    end
    let(:orig_text1) { "\n            アメリカ" }
    let(:orig_text2) { "\n            アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ" }
    let(:orig_text3) { "\n            アメリカ合衆国の旗 アメリカ" }
    it 'finds correspond offset' do
      expect(p.match(orig_text1, 13, 17)).to eq [0, 4]
      expect(p.match(orig_text2, 38, 45)).to eq [25  , 32]
    end

    it 'finds the second one' do
      expect(p.match(orig_text3, 23, 27)).to eq [10, 14]
    end

    context 'with escaped ampersand' do
      let(:p) do
        TaskParagraph.create(
          body: '「アメリスター・カジノ&amp;ホテル」',
          no_tag: '「アメリスター・カジノ&amp;ホテル」'
        )
      end
      let(:orig_text) { "「アメリスター・カジノ&ホテル" }

      it 'resolves escaped html characters' do
        expect(p.match(orig_text, 1, 15)).to eq [1, 19]
      end

      context 'when tagged at the end' do
        let(:p) do
          TaskParagraph.create(
            body: '|起きて寝る -FUNNY DAY &amp; HARD NIGHT-',
            no_tag: '|起きて寝る -FUNNY DAY &amp; HARD NIGHT-'
          )
        end
        let(:orig_text) { "\n              |起きて寝る -FUNNY DAY & HARD NIGHT-" }

        it 'resolves escaped html character and endoffset properly' do
          expect(p.match(orig_text, 16, 46)).to eq [1, 35]
        end
      end
    end

    context 'with escaped >' do
      let(:p) do
        TaskParagraph.create(
          body: '日本 &gt; 近畿地方 &gt; 大阪府 &gt; 八尾市 &gt; 高美町',
          no_tag: '日本 &gt; 近畿地方 &gt; 大阪府 &gt; 八尾市 &gt; 高美町'
        )
      end
      let(:orig_text) { "日本 > 近畿地方" }

      it 'resolves escaped html characters' do
        expect(p.match(orig_text, 5, 9)).to eq [8, 12]
      end

      let(:p2) do
        TaskParagraph.create(
          body: "|<p>&gt;300 °C </p>",
          no_tag: "|&gt;300 °C"
        )
      end
      let(:orig_text2) { "\n              |>300 °C " }

      it 'resolves starts with escaped html characters' do
        expect(p2.match(orig_text2, 16, 23)).to eq [1, 11]
      end
    end
  end
end
