module TasksHelper
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

  def show_paragraph(p)
    if p.tagged
      return p.tagged
    else
      return p.body
    end
  end

  def highlight(html, highlights)
    highlights.each do |v|
      html.gsub! v, "<mark>#{v}</mark>"
    end
    return html
  end

  def undo_disabled?(t)
    return 'disabled' unless t.current_revision
  end

  def redo_disabled?(t)
    return 'disabled' unless t.next_revision
  end
end
