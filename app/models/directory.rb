class Directory < ActiveRecord::Base
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
