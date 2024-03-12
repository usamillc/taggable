class LinkAnnotationsController < ApplicationController
  include EntityLinksHelper

  before_action :logged_in_annotator
  before_action :set_annotation, only: [:show, :update]
  before_action :set_new_link,   only: [:update]

  def show
    @annotation.entity_links.build
    @prev_paragraph = @annotation.merge_tag.paragraph.previous
  end

  def update
    if no_link?
      @annotation.entity_links.map &:rejected!
    else
      begin
        links_param[:entity_links]&.each do |id, param|
          # fill default false
          param[:match] = false unless param[:match]
          param[:later_name] = false unless param[:later_name]
          param[:part_of] = false unless param[:part_of]
          param[:derivation_of] = false unless param[:derivation_of]

          @annotation.entity_links.find_by(id: id).update_attributes!(param)
        end
        @new_link&.save! && LookupPageidJob.perform_async(@new_link.id, :entity_link)
      rescue ActiveRecord::RecordInvalid => e
        title = e.record.id.nil? ? link_param[:new_link][:url] : e.record.title
        e.record.errors.messages.each do |_, messages|
          messages.each do |msg|
            flash[:danger] = "[#{title}]: #{msg}"
            return redirect_to link_annotation_url(@annotation, anchor: 'current')
          end
        end
      end
    end

    unless @annotation.entity_links.any? { |e| e.approved? } || no_link?
      flash[:danger] = "該当するリンク先がない場合は「該当リンク先なし」を選択してください"
      return redirect_to link_annotation_url(@annotation, anchor: 'current')
    end

    @annotation.completed!

    if @annotation.next
      return redirect_to link_annotation_url(@annotation.next, anchor: 'current')
    end
    redirect_to link_task_url(@annotation.link_task)
  end

  private

  def set_annotation
    @annotation = LinkAnnotation.find_by(id: params[:id])
  end

  def set_new_link
    if link_param[:new_link] && link_param[:new_link][:url].present?
      @new_link = EntityLink.new(link_param[:new_link].tap { |h| h.delete(:url) })
        .tap { |e| e.link_annotation = @annotation }
        .tap { |e| e.title = parse_title(link_param[:new_link][:url], @annotation.page.version) }
    end
  end

  def links_param
    params.require(:link_annotation).permit(entity_links: [:id, :status, :match, :later_name, :part_of, :derivation_of])
  end

  def link_param
    params.require(:link_annotation).permit(new_link: [:status, :url, :match, :later_name, :part_of, :derivation_of])
  end

  def no_link?
    param = params.require(:link_annotation).permit(:no_link)
    ActiveModel::Type::Boolean.new.cast(param[:no_link])
  end
end
