require 'rails_helper'

RSpec.feature "Categories", type: :feature do
  given(:admin) { create(:annotator, :admin) }

  background do
    create_list :category, 30
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "index with hidden/active" do
    visit categories_path
    expect(page).to have_selector 'ul.pagination'
    first_page_c = Category.order(created_at: :desc).page(1)
    first_page_c.each do |c|
      expect(page).to have_selector 'th', text: c.id
      expect(page).to have_selector 'td', text: c.screenname
      expect(page).to have_selector 'td', text: "(#{c.name})"
    end
    top_c = Category.last
    # hidden
    first('tbody tr').click_on '非表示にする'
    expect(page).to have_css '.alert-success', text: "カテゴリ #{top_c.screenname} (#{top_c.name}) を非表示に変更しました"
    expect(current_path).to eq categories_path
    expect(page).not_to have_selector 'td', text: top_c.screenname
    click_on '全て'
    # active
    first('tbody tr').click_on '表示する'
    expect(page).to have_css '.alert-success', text: "カテゴリ #{top_c.screenname} (#{top_c.name}) を表示中に変更しました"
    expect(current_path).to eq categories_path
    click_on '表示中のみ'
    expect(page).to have_selector 'td', text: top_c.screenname
  end

  scenario "un/successful create and update", js: true do
    visit categories_path
    # unsuccess
    click_on '+ 新しいカテゴリの追加'
    sleep 0.5
    fill_in 'category_screenname', with: ' '
    expect { click_on '作成' }.not_to change { Category.count }
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq categories_path
    click_on '+ 新しいカテゴリの追加'
    sleep 0.5
    fill_in 'category_screenname', with: Category.last.screenname
    expect { click_on '作成' }.not_to change { Category.count }
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq categories_path
    # success
    click_on '+ 新しいカテゴリの追加'
    sleep 0.5
    fill_in 'category_screenname', with: '島名'
    fill_in 'category_name',       with: 'island'
    fill_in 'category_def_link',   with: 'aaa'
    expect { click_on '作成' }.to change { Category.count }.by(1)
    top_c = Category.last
    expect(page).to have_css '.alert-success', text: "カテゴリ ##{top_c.id} #{top_c.screenname} (#{top_c.name}) を作成しました。"
    expect(current_path).to eq categories_path
    # unsuccess
    first('tbody tr').click_on '変更'
    first('tbody tr').click_on '名称等変更'
    sleep 0.5
    fill_in 'category_screenname', with: ' '
    click_on '変更完了'
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq categories_path
    # success
    first('tbody tr').click_on '変更'
    first('tbody tr').click_on '名称等変更'
    sleep 0.5
    fill_in 'category_screenname', with: '山地名'
    fill_in 'category_name',       with: 'mountain'
    fill_in 'category_def_link',   with: 'bbb'
    click_on '変更完了'
    top_c.reload
    expect(page).to have_css '.alert-success', text: "カテゴリ ##{top_c.id} の名称を #{top_c.screenname} (#{top_c.name}) に変更しました。"
    expect(current_path).to eq categories_path
  end
end
