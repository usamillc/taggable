module MergeTasksHelper
  def show_status(status)
    case status
    when 'not_started'
      '未着手'
    when 'in_progress'
      '作業中'
    when 'completed'
      '完了'
    end
  end
end
