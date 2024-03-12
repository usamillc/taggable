require 'rails_helper'

RSpec.feature "Imports", type: :feature do
  given!(:category) { create :category }
  given(:admin) { create(:annotator, :admin) }

  background do
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "create, extra create and error", js: true do
    visit categories_path
    click_on 'インポート'
    click_on 'タスクインポート'
    sleep 0.5
    attach_file 'import_list', "#{Rails.root}/spec/factories/sample_1.csv"
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    expect(page).to have_selector 'h4', text: 'インポート結果一覧'
    expect(current_path).to eq imports_path(category)
    visit current_path
    import_1 = Import.first
    expect(page).to have_selector 'td', text: import_1.list.filename
    expect(page).to have_selector 'td', text: import_1.annotator.screenname
    expect(page).to have_selector 'td', text: import_1.created_at.strftime('%Y/%m/%d %H:%M')
    expect(page).to have_selector 'td', text: import_1.tasks_to_import
    expect(page).to have_selector 'td', text: import_1.tasks.count
    # extra create
    click_on '+ アノテーションタスクの追加インポート'
    sleep 0.5
    attach_file 'import_list', "#{Rails.root}/spec/factories/sample_2.csv"
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all
    expect(page).to have_selector 'h4', text: 'インポート結果一覧'
    expect(current_path).to eq imports_path(category)
    visit current_path
    import_2 = Import.second
    expect(page).to have_selector 'td', text: import_2.list.filename
    expect(page).to have_selector 'td', text: import_2.annotator.screenname
    expect(page).to have_selector 'td', text: import_2.created_at.strftime('%Y/%m/%d %H:%M')
    expect(page).to have_selector 'td', text: import_2.tasks_to_import
    expect(page).to have_selector 'td', text: import_2.tasks.count
    # error
    click_on '+ アノテーションタスクの追加インポート'
    sleep 0.5
    attach_file 'import_list', "#{Rails.root}/spec/factories/sample_3.csv"
    click_on 'インポート開始'
    Sidekiq::Worker.drain_all rescue
    expect(page).to have_selector 'h4', text: 'インポート結果一覧'
    expect(current_path).to eq imports_path(category)
    visit current_path
    import_3 = Import.third
    expect(page).to have_selector 'td', text: import_3.list.filename
    expect(page).to have_selector 'td', text: import_3.annotator.screenname
    expect(page).to have_selector 'td', text: import_3.created_at.strftime('%Y/%m/%d %H:%M')
    expect(page).to have_selector 'td', text: import_3.tasks_to_import
    expect(page).to have_selector 'td', text: import_3.tasks.count
#    click_on '1'
#    expect(current_path).to eq import_errors_path(import_3.id)
#    expect(page).to have_content 'HTMLファイルがダウンロードできませんでした'
#    expect(page).to have_selector 'td', text: Import_error.first.created_at.strftime('%Y/%m/%d %H:%M')
  end
end
