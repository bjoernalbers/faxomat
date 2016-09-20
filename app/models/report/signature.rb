class Report::Signature < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :user, uniqueness: { scope: :report }
end
