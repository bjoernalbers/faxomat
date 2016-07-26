class Export < ActiveRecord::Base
  include Deliverable

  belongs_to :directory,
    required: true

  validates :filename,
    presence: true
end
