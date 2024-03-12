class Import < ApplicationRecord
  has_one_attached :list

  belongs_to :category
  belongs_to :annotator

  has_many :tasks
  has_many :import_errors
end
