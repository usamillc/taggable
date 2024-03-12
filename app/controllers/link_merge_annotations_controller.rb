class LinkMergeAnnotationsController < ApplicationController
  include EntityLinksHelper

  before_action :logged_in_annotator
  before_action :set_annotation, only: [:show, :update]
  before_action :set_new_link, only: [:update]

  def show
    @annotation.annotated_entity_links.build
    @prev_paragraph = @annotation.merge_tag.paragraph.previous
  end

  def update
    unless no_link? || any_approved?
      flash[:danger] = "該当するリンク先がない場合は「該当リンク先なし」を選択してください"
      return redirect_to link_merge_annotation_url(@annotation, anchor: 'current')
    end
    if no_link? && any_approved?
      flash[:danger] = "リンク先の採用と「該当リンク先なし」を同時に選択することはできません"
      return redirect_to link_merge_annotation_url(@annotation, anchor: 'current')
    end

    if no_link?
      @annotation.annotated_entity_links.map(&:rejected!)
    else
      begin
        links_param[:annotated_entity_links]&.each do |id, param|
          [:match, :later_name, :part_of, :derivation_of].each do |link_type|
            param[link_type] = false unless param[link_type]
          end
          @annotation.annotated_entity_links.find_by(id: id).update_attributes!(param)
        end
        @new_link&.save! && LookupPageidJob.perform_async(@new_link.id, :annotated_entity_link)
      rescue ActiveRecord::RecordInvalid => e
        title = e.record.id.nil? ? new_link_param[:new_link][:url] : e.record.title
        e.record.errors.messages.each do |_, messages|
          messages.each do |msg|
            flash[:danger] = "[#{title}]: #{msg}"
          end
        end

        return redirect_to link_merge_annotation_url(@annotation, anchor: 'current')
      end
    end

    @annotation.completed!

    if @annotation.next
      redirect_to link_merge_annotation_url(@annotation.next, anchor: 'current')
    else
      redirect_to link_merge_task_url(@annotation.link_merge_task)
    end
  end

  private

  def set_annotation
    @annotation = LinkMergeAnnotation.find_by(id: params[:id])
  end

  def set_new_link
    if new_link_param[:new_link]&.fetch(:url)&.present?
      @new_link = AnnotatedEntityLink.new(new_link_param[:new_link].tap { |h| h.delete(:url) })
        .tap { |e| e.link_merge_annotation = @annotation }
        .tap { |e| e.title = parse_title(new_link_param[:new_link][:url], @annotation.page.version) }
    end
  end

  def no_link?
    param = params.require(:link_merge_annotation).permit(:no_link)
    ActiveModel::Type::Boolean.new.cast(param[:no_link])
  end

  def links_param
    params.require(:link_merge_annotation).permit(annotated_entity_links: [:id, :status, :match, :later_name, :part_of, :derivation_of])
  end

  def new_link_param
    params.require(:link_merge_annotation).permit(new_link: [:status, :url, :match, :later_name, :part_of, :derivation_of])
  end

  def any_approved?
    links_param[:annotated_entity_links]&.values&.any? { |param| param[:status] == "approved" } || new_link_param[:new_link]&.fetch(:status) == "approved"
  end
end
