class Delivery < ActiveRecord::Base
  include Deliverable

  enum status: { active: 0, completed: 1, aborted: 2 }

  belongs_to :printer, required: true

  before_destroy :check_if_aborted

  class << self
    def active_or_completed
      where(status: %w(active completed).map { |status| statuses[status] })
    end
  end

  private

  def check_if_aborted
    unless aborted?
      self.errors[:base] << 'Nur abgebrochene Versendungen können gelöscht werden.'
      false
    end
  end
end
