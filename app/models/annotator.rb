class Annotator < ApplicationRecord
  attr_accessor :remember_token

  belongs_to :organization
  has_many :annotations
  has_many :tasks
  has_many :pages, through: :tasks
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :screenname, presence: true
  validates :password, presence: true, length: { minimum: 6 }, confirmation: { case_sensitive: true }

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = Annotator.new_token
    update_attribute(:remember_digest, Annotator.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def merge_allowed?
    organization.name == 'TeamANDO'
  end
end
