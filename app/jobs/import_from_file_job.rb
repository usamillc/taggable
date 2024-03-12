class ImportFromFileJob < SidekiqJob
  require 'csv'

  sidekiq_retries_exhausted do |msg, exception|
    import_id = msg['job']['args'][0]
    import = Import.find(import_id)

    Rails.logger.error msg
    Rails.logger.error exception
    case exception
    when ActiveStorage::FileNotFoundError then
      import.import_errors.create(message: 'csvファイルのダウンロードに失敗しました', error: exception)
    else
      import.import_errors.create(message: 'エラーが発生しました', error: exception)
    end
  end

  def perform(import_id)
    import = Import.find(import_id)

    c = 0
    csvbody = import.list.attachment.blob.download.force_encoding('utf-8').strip

    CSV.parse(csvbody, headers: false) do |row|
      aid, pageid, title =  row[0..2]
      CreateTaskJob.perform_async(
        import.id,
        aid,
        pageid,
        title
      )
      c += 1
    end

    import.update_attribute(:tasks_to_import, c)
  end
end
