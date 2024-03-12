class AnnotationAttribute < ApplicationRecord
  before_save :set_tag

  belongs_to :category
  has_many :annotations, -> { where(deleted: false) }

  validates :name, presence: true, uniqueness: { scope: :category_id }
  validates :screenname, presence: true, uniqueness: { scope: :category_id }

  def self.swap(a1, a2)
    ActiveRecord::Base.transaction do
      a1.ord, a2.ord = a2.ord, a1.ord
      a1.save!
      a2.save!
    end
  end

  class << self
    def find_upper_ord_one(a)
      if result = where(category_id: a.category_id).where('ord < ?', a.ord).order(ord: :desc).first
        result
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def find_lower_ord_one(a)
      if result = where(category_id: a.category_id).where('ord > ?', a.ord).order(ord: :asc).first
        result
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  private

  def set_tag
    self.tag = name.upcase
  end
end
