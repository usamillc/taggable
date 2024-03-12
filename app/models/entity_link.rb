class EntityLink < ApplicationRecord
  validates :title, presence: { message: 'mediawikiのURLを正しく入力してください。' }
  # validates :pageid, presence: true
  validate  :link_type_match_should_be_mutual_exclusive
  validate  :link_type_should_be_assigned, :if => lambda{ |o| o.approved? }

  belongs_to :link_annotation

  has_one :merge_tag, through: :link_annotation
  has_one :merge_value, through: :merge_tag
  has_one :merge_attribute, through: :merge_value

  enum status: [:suggested, :approved, :rejected]

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
end
