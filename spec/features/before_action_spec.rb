require 'rails_helper'

RSpec.feature "BeforeAction", type: :feature do
  given(:annotator) { create :annotator }

  scenario "logged_in_annotator" do
    visit edit_annotator_path(annotator)
    expect(page).to have_css '.alert-danger', text: 'ログインが必要です。'
    expect(current_path).to eq login_path
  end

  scenario "logged_in_admin" do
    visit login_path
    fill_in 'ユーザー名', with: annotator.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
    visit annotators_path
    expect(page).to have_css '.alert-danger', text: '管理者専用ページです。'
    expect(current_path).to eq root_path
  end
end
