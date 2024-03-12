require 'rails_helper'

RSpec.feature "AnnotatorsIndex", type: :feature do
  given!(:org) { create :organization }
  given(:admin) { create(:annotator, :admin, organization: org) }

  background do
    create_list(:annotator, 30, organization: org)
  end

  scenario "index, toggle and delete" do
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
    visit annotators_path
    expect(page).to have_selector 'ul.pagination'
    click_on 'Last'
    expect(page).to have_selector 'td', text: 'あり'
    # 作業中と完了のカウントはtasks_specでテスト
    expect(page).to have_no_link '削除', href: destroy_annotator_path(admin)
    click_on 'First'
    first_page_a = Annotator.where(organization: org).page(1)
    first_page_a.each do |a|
      expect(page).to have_selector 'td', text: a.id
      expect(page).to have_selector 'td', text: a.username
      expect(page).to have_selector 'td', text: a.screenname
    end
    non_admin = Annotator.where(organization: org).first
    click_link '管理者権限を付与', href: toggle_admin_path(non_admin)
    non_admin.reload
    expect(non_admin.admin?).to be_truthy
    expect(current_path).to eq annotators_path
    click_link '管理者権限をなくす', href: toggle_admin_path(non_admin)
    non_admin.reload
    expect(non_admin.admin?).to be_falsey
    expect(current_path).to eq annotators_path
    click_link '削除', href: destroy_annotator_path(non_admin)
    non_admin.reload
    expect(non_admin.deleted?).to be_truthy
    expect(page).to have_css '.alert-success'
    expect(current_path).to eq annotators_path
  end
end
