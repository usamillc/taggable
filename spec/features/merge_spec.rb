require 'rails_helper'

RSpec.feature "Merge", type: :feature do
  given!(:whs) { create(:category, :whs) }
  given!(:city) { create(:annotation_attribute, :city, category: whs) }
  given!(:team_ando) { create(:organization, name: 'TeamANDO') }
  given(:admin) { create(:annotator, :admin, organization: team_ando) }

  background do
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "index and show", js: true do
    visit categories_path
    click_on 'インポート'
    click_on 'タスクインポート'
    sleep 0.5
    attach_file 'import_list', "#{Rails.root}/spec/factories/sample_2.csv"
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    click_on 'ページ移動'
    click_on '抽出作業ページへ'
    click_on '作業を開始する'
    page.execute_script("const selection = window.getSelection(); const range = document.createRange(); const textNode = document.querySelector('h1').firstChild; range.setStart(textNode, 0); range.setEnd(textNode, 6); selection.removeAllRanges(); selection.addRange(range);")
    find('body').native.send_key('z')
    click_on '作業を完了する'
    click_on 'ページ移動'
    click_on '管理者ページへ'
    click_on 'インポート'
    click_on 'マージインポート'
    sleep 0.5
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    expect(current_path).to eq categories_path
    click_on 'ページ移動'
    click_on 'マージ作業ページへ'
    expect(current_path).to eq merge_tasks_path
    m = MergeTask.first
    expect(page).to have_link '全て', href: merge_tasks_path, count: 2
    expect(page).to have_link whs.screenname, href: merge_tasks_path(category_id: whs.id)
    expect(page).to have_selector 'td', text: m.page.aid
    expect(page).to have_selector 'td', text: m.page.title
    expect(page).to have_selector 'td', text: whs.screenname
    expect(page).to have_selector 'td', text: '未着手'
    expect(page).to have_selector 'td', text: m.last_changed_annotator&.screenname
    expect(page).to have_selector 'td', text: m.updated_at.strftime('%Y/%m/%d %H:%M')
    click_on 'ベームスター干拓地'
    expect(page).to have_link '属性定義一覧を別ウィンドウでひらく'
    expect(page).to have_link '元記事を別ウィンドウでひらく'
    click_on 'Mergeable'
    click_on '作業を開始する'
    click_on 'この属性の作業を完了する'
    expect(current_path).to eq merge_task_path(m)
    click_on '中断して一覧へ戻る'
    # filter
    click_on '未着手'
    expect(page).not_to have_content 'ベームスター干拓地'
    click_on '作業中'
    click_on '作業を完了する'
    expect(current_path).to eq merge_tasks_path
    expect(page).not_to have_content 'ベームスター干拓地'
    click_on '完了'
    expect(page).to have_content 'ベームスター干拓地'
    click_on '作業を再開する'
    click_on '作業を完了する'
    expect(current_path).to eq merge_tasks_path
  end
end
