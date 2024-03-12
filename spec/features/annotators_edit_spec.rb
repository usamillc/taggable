require 'rails_helper'

RSpec.feature "AnnotatorsEdit", type: :feature do
  given(:annotator) { create :annotator }

  background do
    visit login_path
    fill_in 'ユーザー名', with: annotator.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "unsuccessful edit" do
    visit edit_annotator_path(annotator)
    fill_in 'annotator_username',   with: ' '
    fill_in 'annotator_screenname', with: ' '
    fill_in 'annotator_password',   with: 'foo'
    fill_in 'annotator_password_confirmation', with: 'bar'
    click_on '変更'
    expect(page).to have_css '.alert-danger'
    expect(page).to have_selector 'h3', text: 'ユーザー情報の変更'
  end

  scenario "successful edit" do
    visit edit_annotator_path(annotator)
    fill_in 'annotator_username',   with: 'example'
    fill_in 'annotator_screenname', with: 'EXAMPLE'
    fill_in 'annotator_password',   with: '123456'
    fill_in 'annotator_password_confirmation', with: '123456'
    click_on '変更'
    expect(page).to have_css '.alert-success', text: 'ユーザー情報を更新しました。'
    expect(current_path).to eq tasks_path
    annotator.reload
    expect(annotator.username).to eq 'example'
    expect(annotator.screenname).to eq 'EXAMPLE'
  end
end
