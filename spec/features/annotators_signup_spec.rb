require 'rails_helper'

RSpec.feature "AnnotatorsSignup", type: :feature do
  given(:admin) { create(:annotator, :admin) }

  background do
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "invalid signup information" do
    visit annotators_path
    click_on '+ 追加'
    fill_in 'annotator_username',   with: ' '
    fill_in 'annotator_screenname', with: ' '
    fill_in 'annotator_password',   with: 'foo'
    fill_in 'annotator_password_confirmation', with: 'bar'
    expect{ click_on '追加' }.not_to change { Annotator.count }
    expect(page).to have_css '.alert-danger'
    expect(page).to have_selector 'h3', text: 'アノテーターの追加'
  end

  scenario "valid signup information" do
    visit new_annotator_path
    fill_in 'annotator_username',   with: 'example'
    fill_in 'annotator_screenname', with: 'EXAMPLE'
    fill_in 'annotator_password',   with: '123456'
    fill_in 'annotator_password_confirmation', with: '123456'
    expect{ click_on '追加' }.to change { Annotator.count }.by(1)
    expect(page).to have_css '.alert-success'
    expect(current_path).to eq annotators_path
  end
end
