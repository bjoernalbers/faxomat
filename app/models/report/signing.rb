class Report::Signing < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :user, uniqueness: {
    scope: :report, message: 'hat Bericht bereits unterschrieben' }

  delegate :signature_path, :full_name, :suffix, to: :user
end
