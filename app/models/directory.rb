class Directory < ActiveRecord::Base
  has_many :exports,
    dependent: :restrict_with_error

  attribute :path, Path.new

  validates :description,
    presence: true
  validates :path,
    presence: true,
    directory: true

  class << self
    def default
      first
    end
  end
end
