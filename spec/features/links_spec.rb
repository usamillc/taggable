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
    attach_file 'import_list', "#{Rails.root}/spec/factories/sample_1.csv"
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    click_on 'ページ移動'
    click_on '抽出作業ページへ'
    click_on '作業を開始する'
    page.execute_script("const selection = window.getSelection(); const range = document.createRange(); const textNode = document.querySelector('h1').firstChild; range.setStart(textNode, 0); range.setEnd(textNode, 7); selection.removeAllRanges(); selection.addRange(range);")
    find('body').native.send_key('z')
    click_on '作業を完了する'
    click_on 'ページ移動'
    click_on '管理者ページへ'
    click_on 'インポート'
    click_on 'マージインポート'
    sleep 0.5
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    click_on 'ページ移動'
    click_on 'マージ作業ページへ'
    click_on '作業を開始する'
    click_on 'この属性の作業を完了する'
    click_on '作業を完了する'
#    click_on 'ページ移動'
#    click_on '管理者ページへ'
#    click_on 'インポート'
#    click_on 'リンクインポート'
#    sleep 0.5
#    click_on 'インポート開始'
#    Sidekiq::Worker.drain_all
#    expect(current_path).to eq categories_path
    l = LinkTask.create(page: MergeTask.first.page)
    LinkAnnotation.create(link_task: l, merge_tag: MergeTag.first)
    click_on 'ページ移動'
    click_on 'リンク作業ページへ'
    expect(current_path).to eq link_tasks_path
    expect(page).to have_link '全て', href: link_tasks_path, count: 2
    expect(page).to have_link whs.screenname, href: link_tasks_path(category_id: whs.id)
    expect(page).to have_selector 'td', text: l.page.aid
    expect(page).to have_selector 'td', text: l.page.title
    expect(page).to have_selector 'td', text: whs.screenname
    expect(page).to have_selector 'td', text: '未着手'
    expect(page).to have_selector 'td', text: l.last_changed_annotator&.screenname
    expect(page).to have_selector 'td', text: l.updated_at.strftime('%Y/%m/%d %H:%M')
    click_on 'アムステルダムの防塞線'
    expect(current_path).to eq link_annotation_path(LinkAnnotation.first)
    click_on '参照用リンク'
    expect(page).to have_link '属性定義一覧'
    expect(page).to have_link '元記事'
    expect(page).to have_link 'マージツールで修正'
    click_on 'Linkable'
    click_on '作業を開始する'
    # no check
    click_on '保存'
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq link_annotation_path(LinkAnnotation.first)
    # check and blank
    check 'link_annotation_new_link_status'
    click_on '保存'
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq link_annotation_path(LinkAnnotation.first)
    # check and invalid url
    check 'link_annotation_new_link_status'
    fill_in 'link_annotation_new_link_url', with: 'test'
    click_on '保存'
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq link_annotation_path(LinkAnnotation.first)
    # check and valid url with no entity list
    check 'link_annotation_new_link_status'
    fill_in 'link_annotation_new_link_url', with: 'https://ja.mediawiki.usami.llc/wiki/アムステルダム'
    click_on '保存'
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq link_annotation_path(LinkAnnotation.first)
    # check and valid url with full entity list
    check 'link_annotation_new_link_status'
    fill_in 'link_annotation_new_link_url', with: 'https://ja.mediawiki.usami.llc/wiki/アムステルダム'
    check 'link_annotation_new_link_match'
    check 'link_annotation_new_link_later_name'
    check 'link_annotation_new_link_part_of'
    check 'link_annotation_new_link_derivation_of'
    click_on '保存'
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq link_annotation_path(LinkAnnotation.first)
    # check no_link
    check 'link_annotation_no_link'
    click_on '保存'
    expect(page).not_to have_css '.alert-danger'
    expect(current_path).to eq link_task_path(LinkAnnotation.first.link_task)
    click_on '作業'
    click_on '中断して一覧へ戻る'
    # filter
    click_on '未着手'
    expect(page).not_to have_content 'アムステルダムの防塞線'
    click_on '作業中'
    click_on '作業を完了する'
    expect(current_path).to eq link_tasks_path
    click_on '作業中'
    expect(page).not_to have_content 'アムステルダムの防塞線'
    click_on '完了'
    expect(page).to have_content 'アムステルダムの防塞線'
    click_on '作業を再開する'
    click_on '作業'
    click_on '作業を完了する'
    expect(current_path).to eq link_tasks_path
  end
end
