class Organization < ApplicationRecord
  has_many :annotators, -> { where(deleted: false).order(:id) }
  has_many :tasks
  has_many :pages, through: :tasks
  has_many :categories, -> { distinct }, through: :pages
  has_many :merge_tasks, through: :pages
end
