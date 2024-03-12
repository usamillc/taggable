require 'rails_helper'

RSpec.feature "AnnotationAttributes", type: :feature do
  given!(:aa) { create :annotation_attribute }
  given(:admin) { create(:annotator, :admin) }

  background do
    visit login_path
    fill_in 'ユーザー名', with: admin.username
    fill_in 'パスワード', with: '123456'
    click_on 'ログイン'
  end

  scenario "index with toggle_linkable, un/successful create and up/down_ord" do
    visit categories_path
    click_on '属性変更'
    expect(page).to have_selector 'h4', text: '属性一覧 (全 1 属性)'
    expect(page).to have_selector 'td', text: aa.screenname
    expect(page).to have_selector 'td', text: aa.name
    expect(page).to have_selector 'td', text: aa.annotations.count
    # toggle_linkable
    expect { click_on '対象外にする' }.to change { aa.reload.linkable? }.from(be_truthy).to(be_falsey)
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq attributes_index_path(aa.category)
    expect { click_on '対象にする' }.to change { aa.reload.linkable? }.from(be_falsey).to(be_truthy)
    expect(page).to have_css '.alert-success'
    expect(current_path).to eq attributes_index_path(aa.category)
    # unsuccess
    within all('tbody tr').last do
      fill_in 'annotation_attribute_screenname', with: ' '
      fill_in 'annotation_attribute_name',       with: ' '
    end
    expect { click_on '追加' }.not_to change { AnnotationAttribute.count }
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq attributes_index_path(aa.category)
    # success
    within all('tbody tr').last do
      fill_in 'annotation_attribute_screenname', with: '別名'
      fill_in 'annotation_attribute_name',       with: 'alias'
    end
    expect { click_on '追加' }.to change { AnnotationAttribute.count }.by(1)
    expect(current_path).to eq attributes_index_path(aa.category)
    # up/down
    aa_2 = AnnotationAttribute.second
    expect(page).to have_no_link href: up_attribute_path(aa)
    expect(page).to have_no_link href: down_attribute_path(aa_2)
    click_link href: down_attribute_path(aa)
    expect(current_path).to eq attributes_index_path(aa.category)
    expect(page).to have_no_link href: up_attribute_path(aa_2)
    expect(page).to have_no_link href: down_attribute_path(aa)
    click_link href: up_attribute_path(aa)
    expect(current_path).to eq attributes_index_path(aa.category)
    expect(page).to have_no_link href: up_attribute_path(aa)
    expect(page).to have_no_link href: down_attribute_path(aa_2)
  end

  scenario "un/successful update and delete", js: true do
    visit attributes_index_path(aa.category)
    # unsuccess
    click_on '変更'
    sleep 0.5
    within 'div.modal-body' do
      fill_in 'annotation_attribute_screenname', with: ' '
      fill_in 'annotation_attribute_name',       with: ' '
    end
    within 'div.modal-footer' do
      click_on '変更'
    end
    expect(page).to have_css '.alert-danger'
    expect(current_path).to eq attributes_index_path(aa.category)
    # success
    click_on '変更'
    sleep 0.5
    within 'div.modal-body' do
      fill_in 'annotation_attribute_screenname', with: '別名'
      fill_in 'annotation_attribute_name',       with: 'alias'
    end
    within 'div.modal-footer' do
      click_on '変更'
    end
    previous = "#{aa.screenname} (#{aa.name})"
    aa.reload
    expect(page).to have_css '.alert-success', text: "属性 #{previous} の名称を #{aa.screenname} (#{aa.name}) に変更しました。"
    expect(current_path).to eq attributes_index_path(aa.category)
    # delete
    click_on 'delete'
    sleep 0.5
    within 'div.modal-footer' do
      click_on '削除'
    end
    aa.reload
    expect(aa.deleted?).to be_truthy
    expect(page).to have_css '.alert-success', text: "属性 #{aa.screenname} (#{aa.name}) を削除しました"
    expect(current_path).to eq attributes_index_path(aa.category)
  end
end
