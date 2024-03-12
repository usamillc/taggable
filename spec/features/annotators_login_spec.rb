require 'rails_helper'

RSpec.feature "AnnotatorsLogin", type: :feature do
  given(:annotator) { create :annotator }

  scenario "login with invalid password" do
    visit login_path
    fill_in 'ユーザー名', with: annotator.username
    fill_in 'パスワード', with: 'invalid'
    click_on 'ログイン'
    expect(page).to have_css '.alert-danger', text: 'usernameとpasswordが一致しません'
    expect(page).to have_selector 'h1', text: 'ログイン'
    visit login_path
    expect(page).to have_no_css '.alert-danger'
  end

  scenario "login with valid information" do
    visit login_path
    fill_in 'ユーザー名', with: annotator.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
    expect(current_path).to eq tasks_path
  end
end
