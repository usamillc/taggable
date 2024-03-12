class CreateTaskJob < SidekiqJob
  include PagesHelper
  include ApplicationHelper

  class PageNotFound < StandardError
  end

  sidekiq_retries_exhausted do |msg, exception|
    import_id, aid, pageid, title = msg['args']
    import = Import.find(import_id)

    case exception
    when PageNotFound then
      import.import_errors.create(message: "HTMLファイルがダウンロードできませんでした: aid[#{aid}], pageid[#{pageid}], title[#{title}]", error: exception)
    else
      import.import_errors.create(message: "エラーが発生しました: aid[#{aid}], pageid[#{pageid}], title[#{title}]", error: exception)
    end
  end

  def perform(import_id, aid, pageid, title)
    import = Import.find(import_id)

    ActiveRecord::Base.transaction do
      page = Page.create!(aid: aid, pageid: pageid, title: title, category: import.category)

      htmlfile = "/tmp/#{pageid}"

      unless system "wget #{pages_url(pageid)} -O #{htmlfile}"
        raise PageNotFound.new
      end

      load_html(page, htmlfile)

      Task.import(import, page)
    end
  end
end
