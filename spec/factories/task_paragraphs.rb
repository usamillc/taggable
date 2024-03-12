FactoryBot.define do
  factory :task_paragraph do
    task
    paragraph { build(:paragraph, page: task.page) }
    body { "| (1936-10-03) 1936年10月3日（81歳） アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ" }
    no_tag { "| (1936-10-03) 1936年10月3日（81歳） アメリカ合衆国の旗 アメリカ合衆国、ニューヨーク市ブロードウェイ" }

    trait :with_html_tags do
      body { "<p>スティーヴ・ライヒ（Steve Reich, 1936年10月3日 - ）は、ミニマル・ミュージックを代表するアメリカの作曲家。母は女優のジューン・キャロル（English版）（旧姓・シルマン）。異父弟に作家のジョナサン・キャロル。</p>" }
      no_tag { "スティーヴ・ライヒ（Steve Reich, 1936年10月3日 - ）は、ミニマル・ミュージックを代表するアメリカの作曲家。母は女優のジューン・キャロル（English版）（旧姓・シルマン）。異父弟に作家のジョナサン・キャロル。" }
    end
  end
end
