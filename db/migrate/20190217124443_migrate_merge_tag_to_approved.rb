class MigrateMergeTagToApproved < ActiveRecord::Migration[5.2]
  def up
    progressbar = ProgressBar.create format: '%a %e %p% Processed: %c / %C'
    progressbar.total = MergeTag.not_approved.count

    MergeTag.not_approved.each do |mt|
      begin
        mt.approved!
      rescue ActiveRecord::RecordInvalid
      end
      progressbar.increment
    end
  end
end
