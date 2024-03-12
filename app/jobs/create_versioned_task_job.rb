class CreateVersionedTaskJob < SidekiqJob
  include PagesHelper
  include ApplicationHelper

  class PageNotFound < StandardError
  end

  sidekiq_retries_exhausted do |msg, exception|
    aid, pageid, title, _, version, _ = msg['args']

    case exception
    when PageNotFound then
      puts "HTMLファイルがダウンロードできませんでした: aid[#{aid}], version[#{version}], pageid[#{pageid}], title[#{title}]"
    else
      puts "エラーが発生しました: aid[#{aid}], version[#{version}], pageid[#{pageid}], title[#{title}]"
    end
  end

  def perform(aid, pageid, title, category_id, version, org_id)
    ActiveRecord::Base.transaction do
      page = Page.create!(aid: aid, pageid: pageid, title: title, category_id: category_id, version: version)

      htmlfile = "/tmp/#{pageid}"

      unless system "wget #{pages_versioned_url(version, pageid)} -O #{htmlfile}"
        raise PageNotFound.new
      end

      load_html(page, htmlfile)

      t = Task.create!(page: page, organization_id: org_id)
      page.paragraphs.each do |p|
        TaskParagraph.create!(paragraph: p, task: t, body: p.body, no_tag: p.no_tag)
      end
    end
  end
end
