require 'rails_helper'
include ApplicationHelper

RSpec.feature "Tasks", type: :feature do
  given!(:whs) { create(:category, :whs) }
  given!(:city) { create(:annotation_attribute, :city, category: whs) }
  given(:admin) { create(:annotator, :admin) }

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
    attach_file 'import_list', "#{Rails.root}/spec/factories/sample_1.csv"
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    click_on 'ページ移動'
    click_on '抽出作業ページへ'
    task = Task.first
    expect(page).to have_link '全て', href: root_path, count: 2
    expect(page).to have_link whs.screenname, href: root_path(category_id: whs.id)
    expect(page).to have_selector 'td', text: task.page.aid
    expect(page).to have_selector 'td', text: task.page.title
    expect(page).to have_selector 'td', text: whs.screenname
    expect(page).to have_selector 'td', text: '未着手'
    expect(page).to have_selector 'td', text: '0'
    expect(page).to have_selector 'td', text: task.last_changed_annotator&.screenname
    expect(page).to have_selector 'td', text: task.updated_at.strftime('%Y/%m/%d %H:%M')
    click_on 'アムステルダムの防塞線'
    find('#help').click
    sleep 0.5
    expect(page).to have_selector 'h6', text: '作業画面のヘルプ'
    click_on '閉じる'
    click_on 'Taggable'
    # action
    click_on '作業を開始する'
    expect(current_path).to eq task_path(task)
    page.execute_script("const selection = window.getSelection(); const range = document.createRange(); const textNode = document.querySelector('h1').firstChild; range.setStart(textNode, 0); range.setEnd(textNode, 7); selection.removeAllRanges(); selection.addRange(range);")
    find('body').native.send_key('z')
    expect(page).to have_selector '.tag', text: '<CITY>'
    expect(page).to have_selector '.tag', text: '</CITY>'
    expect(page).to have_selector 'mark', text: 'アムステルダム', count: 13
    find('#undo').click
    expect(page).not_to have_selector '.tag', text: '<CITY>'
    expect(page).not_to have_selector '.tag', text: '</CITY>'
    find('#redo').click
    expect(page).to have_selector '.tag', text: '<CITY>'
    expect(page).to have_selector '.tag', text: '</CITY>'
    click_on 'タグ非表示'
    expect(page).not_to have_selector '.tag', text: '<CITY>'
    expect(page).not_to have_selector '.tag', text: '</CITY>'
    click_on 'タグ表示'
    expect(page).to have_selector '.tag', text: '<CITY>'
    expect(page).to have_selector '.tag', text: '</CITY>'
    click_on 'ハイライト非表示'
    expect(page).not_to have_selector 'mark', text: 'アムステルダム'
    click_on '中断して一覧へ戻る'
    visit annotators_path
    expect(page).to have_selector 'td', text: '作業中 1'
    expect(page).to have_selector 'td', text: '完了 0'
    click_on 'ページ移動'
    click_on '抽出作業ページへ'
    # filter
    click_on '未着手'
    expect(page).not_to have_content 'アムステルダムの防塞線'
    click_on '作業中'
    click_on '作業を完了する'
    expect(current_path).to eq tasks_path
    expect(page).not_to have_content 'アムステルダムの防塞線'
    click_on '完了'
    expect(page).to have_content 'アムステルダムの防塞線'
    visit annotators_path
    expect(page).to have_selector 'td', text: '作業中 0'
    expect(page).to have_selector 'td', text: '完了 1'
    click_on 'ページ移動'
    click_on '抽出作業ページへ'
    # sidebar
    click_on '作業を再開する'
    expect(page).to have_link '属性定義一覧を別ウィンドウでひらく', href: whs.def_link
    expect(page).to have_link '元記事を別ウィンドウでひらく', href: pages_url(task.page.pageid)
    find('.highlight-attribute').set(true)
    expect(page).to have_selector 'mark', text: 'アムステルダム', count: 13
    click_on '作業を完了する'
    expect(current_path).to eq tasks_path
  end
end
