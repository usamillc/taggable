require 'rails_helper'

RSpec.feature "SiteLayout", type: :feature do
  given!(:team_ando) { create(:organization, name: 'TeamANDO') }
  given(:admin) { create(:annotator, :admin, organization: team_ando) }
  given(:annotator) { create :annotator }

  background do
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "nav links" do
    expect(page).to have_link '管理者ページへ',     href: admin_root_path
    expect(page).to have_link '抽出作業ページへ',   href: tasks_path
    expect(page).to have_link 'マージ作業ページへ', href: merge_tasks_path
    expect(page).to have_link 'リンク作業ページへ', href: link_tasks_path
    expect(page).to have_link 'ユーザー情報変更',   href: edit_annotator_path(admin)
    expect(page).to have_link 'ログアウト',         href: logout_path
    visit merge_tasks_path
    expect(page).to have_link '管理者ページへ',     href: admin_root_path
    expect(page).to have_link '抽出作業ページへ',   href: tasks_path
    expect(page).to have_link 'マージ作業ページへ', href: merge_tasks_path
    expect(page).to have_link 'リンク作業ページへ', href: link_tasks_path
    expect(page).to have_link 'ユーザー情報変更',   href: edit_annotator_path(admin)
    expect(page).to have_link 'ログアウト',         href: logout_path
    visit link_tasks_path
    expect(page).to have_link '管理者ページへ',     href: admin_root_path
    expect(page).to have_link '抽出作業ページへ',   href: tasks_path
    expect(page).to have_link 'マージ作業ページへ', href: merge_tasks_path
    expect(page).to have_link 'リンク作業ページへ', href: link_tasks_path
    expect(page).to have_link 'ユーザー情報変更',   href: edit_annotator_path(admin)
    expect(page).to have_link 'ログアウト',         href: logout_path
    click_on 'アカウント'
    click_on 'ログアウト'
    fill_in 'ユーザー名', with: annotator.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
    expect(page).not_to have_link '管理者ページへ', href: admin_root_path
  end

  scenario "adminnav links" do
    visit annotators_path
    expect(page).to have_link 'カテゴリ一覧へ',     href: categories_path
    expect(page).to have_link 'アノテータ一覧へ',   href: annotators_path
    expect(page).to have_link '抽出作業ページへ',   href: tasks_path
    expect(page).to have_link 'マージ作業ページへ', href: merge_tasks_path
    expect(page).to have_link 'リンク作業ページへ', href: link_tasks_path
    expect(page).to have_link 'ユーザー情報変更',   href: edit_annotator_path(admin)
    expect(page).to have_link 'ログアウト',         href: logout_path
  end
end
