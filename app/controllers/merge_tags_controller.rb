class MergeTagsController < ApplicationController
  include AnnotationsHelper

  before_action :set_merge_tag
  before_action :merge_allowed_annotator

  def approve
    @merge_tag.approved!

    head :ok
  end

  def delete
    @merge_tag.deleted!
    @merge_tag.link_annotations.destroy_all

    redirect_back fallback_location: @merge_tag.merge_value
  end

  def create
    value = params[:merge_tag][:value]

    before_end_offset = params[:merge_tag][:end_offset].to_i
    if value.end_with? ' ' or value.end_with? "\n"
      c = value.length
      value.rstrip!
      before_end_offset -= c - value.length
    end

    before_start_offset = params[:merge_tag][:start_offset].to_i
    if value.start_with? ' ' or value.start_with? "\n"
      c = value.length
      value.lstrip!
      before_start_offset -= c - value.length
    end

    p = Paragraph.find(params[:merge_tag][:paragraph_id])
    unless p.no_tag.include? html_escape(value)
      p = p.page.paragraphs.where('id > ?', p.id).order(:id).find { |paragraph| paragraph.no_tag.include? value }
    end

    if p.nil?
      ma = MergeAttribute.find(params[:merge_attribute_id])
      flash[:danger] = 'アノテーションに失敗しました。'
      return redirect_back fallback_location: merge_tasks_path
    end

    ActiveRecord::Base.transaction do
      mv = MergeValue.find_or_create_by!(value: value, merge_attribute_id: params[:merge_attribute_id])

      start_offset, end_offset = p.match(
        params[:merge_tag][:text][0...before_end_offset],
        before_start_offset,
        before_end_offset
      )

      if start_offset.nil? || end_offset.nil? || html_escape(value) != p.no_tag[start_offset...end_offset]
        flash[:danger] = 'アノテーションに失敗しました。'
        return redirect_back fallback_location: merge_tasks_path
      end

      mt = MergeTag.new(
        merge_value: mv,
        paragraph: p,
        start_offset: start_offset,
        end_offset: end_offset,
        status: :approved
      )

      if mt.valid?
        mt.save
        unless p.page.link_tasks.empty?
          linkable = Set.new(p.page.linkable_attributes.pluck(:screenname))
          if linkable.include? mt.merge_attribute.screenname
            p.page.link_tasks.each do |task|
              la = LinkAnnotation.create!(link_task: task, merge_tag: mt)
              GenerateSuggestsJob.perform_async(la.id)
            end
          end
        end
        return redirect_to mv
      else
        flash[:danger] = ''
        mt.errors.each do |_, msg|
          flash[:danger] += msg
        end
        raise ActiveRecord::Rollback
      end
    end
    return redirect_back fallback_location: merge_tasks_path
  end

  private

  def set_merge_tag
    @merge_tag = MergeTag.find_by(id: params[:id])
  end
end
