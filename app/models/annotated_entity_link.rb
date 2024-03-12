class AnnotatedEntityLink < ApplicationRecord
  validates :title, presence: { message: 'mediawikiのURLを正しく入力してください。' }
  validate  :link_type_match_should_be_mutual_exclusive
  validate  :link_type_should_be_assigned, :if => lambda{ |o| o.approved? }

  belongs_to :link_merge_annotation

  has_one :merge_tag, through: :link_merge_annotation
  has_one :merge_value, through: :merge_tag
  has_one :merge_attribute, through: :merge_value

  enum status: [:conflicted, :approved, :rejected]

  class << self
    def create_by_consensus!(link_merge_annotation, entity_links)
      e = entity_links.first
      ael = self.new(
        link_merge_annotation: link_merge_annotation,
        title: e.title,
        pageid: e.pageid,
        first_sentence: e.first_sentence
      )

      entity_links.each do |el|
        ael.countup_annotation(el)
      end

      ael.match         = ael.agreed?(:match)
      ael.later_name    = ael.agreed?(:later_name)
      ael.part_of       = ael.agreed?(:part_of)
      ael.derivation_of = ael.agreed?(:derivation_of)

      ael.save!
      ael
    end
  end

  def countup_annotation(entity_link)
    self.match_count         += 1 if entity_link.match?
    self.later_name_count    += 1 if entity_link.later_name?
    self.part_of_count       += 1 if entity_link.part_of?
    self.derivation_of_count += 1 if entity_link.derivation_of?
  end

  def link_type_match_should_be_mutual_exclusive
    if match && [later_name, part_of, derivation_of].any?
      msg = '完全一致の場合は、その他のリンクタイプを選択することはできません。'
      errors.add(:match, msg)
    end
  end

  def link_type_should_be_assigned
    unless [match, later_name, part_of, derivation_of].any?
      msg = 'リンクタイプが未選択です。'
      errors.add(:status, msg)
    end
  end

  def agreed?(link_type)
    send("#{link_type}_count") == 2
  end
end
