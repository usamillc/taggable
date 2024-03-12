class Page < ApplicationRecord
  include PagesHelper

  delegate :merge_tags, to: :merge_task

  belongs_to :category

  has_many :tasks
  has_many :paragraphs, -> { order 'id ASC' }
  has_many :task_paragraphs, through: :paragraphs
  has_many :annotations, through: :tasks
  has_many :annotation_attributes, through: :category
  has_many :link_tasks
  has_many :linkable_attributes, through: :category

  has_one :current_revision, -> { where(undone: false).order(created_at: :desc) }, class_name: 'Revision'
  has_one :next_revision, -> { where(undone: true).order(created_at: :asc) }, class_name: 'Revision'
  has_one :merge_task
  has_one :link_merge_task

  def refresh!
    return unless can_refresh?

    ActiveRecord::Base.transaction do
      paragraphs.delete_all
      load_html(self, html_file)
    end
  end

  def can_refresh?
    tasks.empty?
  end

  def repair!
    return unless can_repair?

    ok = false
    ActiveRecord::Base.transaction do
      old_task = tasks.first

      paragraphs.delete_all
      transfer_task
      transfer_annotations

      old_task.destroy if old_task
      ok = true
    end

    rebuild_tags if ok
    ok
  end

  def can_repair?
    @new_paragraphs = load_html(nil, html_file, debug=false, return_body=true)
    return identical? || tasks.count < 2 && (annotations.empty? || annotations_transferable?)
  end

  def mergeable?
    tasks.present? && tasks.all? { |t| t.completed? } && merge_task.nil?
  end

  def prepare_merge!
    ActiveRecord::Base.transaction do
      m = MergeTask.create!(page: self)
      annotation_attributes.each do |aa|
        ma = MergeAttribute.create!(merge_task: m, name: aa.name, screenname: aa.screenname)
        Annotation.joins(task_paragraph: :task).where('tasks.page_id = ?', id).where(deleted: false).where(annotation_attribute: aa).includes(task_paragraph: :paragraph).each do |a|
          if a.dummy?
            MergeValue.find_or_create_by!(merge_attribute: ma, value: a.value)
          elsif !a.value.empty? && a.start_offset && a.end_offset
            mv = MergeValue.find_or_create_by!(merge_attribute: ma, value: a.value)
            mv.increment_count!
            mt = MergeTag.create(merge_value: mv, paragraph: a.task_paragraph.paragraph, start_offset: a.start_offset, end_offset: a.end_offset)
            begin
              mt.approved!
            rescue ActiveRecord::RecordInvalid
              # keep tag as not approved when overwrap exists
            end
          end
        end
      end
    end
  end

  def linkable?
    merge_task&.completed? && link_tasks.empty?
  end

  def prepare_link!
    ActiveRecord::Base.transaction do
      2.times do
        LinkTask.prepare!(self)
      end
    end
  end

  def link_mergeable?
    link_tasks.present? && link_tasks.completed.count >= 2 && link_merge_task.nil?
  end

  def prepare_link_merge!
    ActiveRecord::Base.transaction do
      LinkMergeTask.prepare!(self)
    end
  end

  def outputs(html)
    html.sub!(/ - Wikipedia Dump \d+/, '')

    orig_lines = html.split("\n")
    sanitized_lines = sanitize(html).split("\n")

    lineid_map = {}

    byebug

    i = 0
    paragraphs.each do |p|
      next if p.no_tag.empty?
      puts p.body
      while p.body != sanitized_lines[i]
        i += 1
      end
      lineid_map[p.id] = i
    end

    # i = 5
    # no_tag_line = ActionView::Base.white_list_sanitizer.sanitize(lines[i], tags: []).strip
    # paragraphs.each do |p|
    #   if p.no_tag == no_tag_line
    #     lineid_map[p.id] = i
    #     i += 1
    #     no_tag_line = ActionView::Base.white_list_sanitizer.sanitize(lines[i], tags: []).strip
    #   end
    # end
    #
    merge_task.merge_tags.approved.map do |mt|
      {
        "page_id": pageid.to_s,
        "title": title,
        "attribute": mt.merge_attribute.screenname,
        "html_offset": {},
        "text_offset": {
          "start": {
            "line_id": mt.paragraph.id,
            "offset": mt.start_offset,
          },
          "end": {
            "line_id": mt.paragraph.id,
            "offset": mt.end_offset,
          },
          "text": mt.merge_value.value
        },
        "ENE": category.ene_id
      }
    end
  end

  private

  def transfer_task
    t = tasks.first
    return unless t
    @new_task = Task.create!(
      page: self,
      status: t.status,
      updated_at: t.updated_at,
      organization: t.organization,
      annotator_id: t.annotator_id
    )

    @new_task_paragraphs = []
    @new_paragraphs.each do |p|
      next if p.blank?
      no_tag = ActionView::Base.white_list_sanitizer.sanitize(p, tags: []).strip
      paragraph = Paragraph.create!(page: self, body: p, no_tag: no_tag)
      @new_task_paragraphs << TaskParagraph.create!(paragraph: paragraph, task: @new_task, body: paragraph.body, no_tag: paragraph.no_tag)
    end
  end

  def transfer_annotations
    annotations.each do |a|
      next if a.value.empty?
      b = a.task_paragraph.body.gsub(/&lt;(.+?)&gt;/, ' ')
      case a
      when identical_paragraph?
        Rails.logger.debug('identical')
        otps = a.task_paragraph.task.task_paragraphs.select { |tp| tp.body == a.task_paragraph.body }
        tps = @new_task_paragraphs.select { |tp| tp.body == b }
        i = otps.index(a.task_paragraph)
        tp = tps[i]
        unless tp
          debugger
          raise ActiveRecord::Rollback
        end
        a.transfer!(tp, identical=true)
      when partial_match_paragraph?
        Rails.logger.debug('partial')
        b = b.gsub(/<\/td>/, '')
        tp = find_task_paragraph(->tp{ (tp.body.include?(b) || b.include?(tp.body)) && tp.body.scan(a.value).size == 1 })
        a.transfer!(tp)
      when unique_match?
        Rails.logger.debug('unique')
        tp = find_task_paragraph(->tp{ tp.body.scan(a.value).size == 1 })
        a.transfer!(tp)
      else
        debugger
        Rails.logger.debug("no match: #{a.id}")
        raise ActiveRecord::Rollback
      end
    end
  end

  def rebuild_tags
    TaskParagraph.where(id: annotations.pluck(:task_paragraph_id)).map(&:build_tags!)
  end

  def html_file
    "importer/html/#{pageid}.html.gz"
  end

  def identical?
    paragraphs.pluck(:body) == @new_paragraphs
  end

  def annotations_transferable?
    annotations.includes(:task_paragraph).all? { |a| a.value.empty? || identical_paragraph?.call(a) || partial_match_paragraph?.call(a) || unique_match?.call(a) || puts(a.id) }
  end

  def identical_paragraph?
    -> a { @new_paragraphs.include? a.task_paragraph.body.gsub(/&lt;(.+?)&gt;/, ' ') }
  end

  def partial_match_paragraph?
    -> a do
      b = a.task_paragraph.body.gsub(/&lt;(.+?)&gt;/, ' ')
      b = b.gsub(/<\/td>/, '')
      @new_paragraphs.any? do |p|
        (p.include?(b) || b.include?(p)) && p.scan(a.value).size == 1
      end
    end
  end

  def unique_match?
    -> a { @new_paragraphs.join('').scan(a.value).size == 1 }
  end

  def find_task_paragraph(criteria)
    tps = @new_task_paragraphs.select { |tp| criteria.call(tp) }
    unless tps.size == 1
      Rails.logger.debug "duplicates: #{tps.size}"
      raise ActiveRecord::Rollback
    end
    return tps.first
  end
end
