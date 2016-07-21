class Delivery < ActiveRecord::Base
  enum status: { active: 0, completed: 1, aborted: 2 }

  belongs_to :document, required: true
  belongs_to :printer, required: true # TODO: Remove!

  validate :document_is_released_for_delivery, if: :document, on: :create

  before_destroy :check_if_aborted

  class << self
    def active_or_completed
      where(status: %w(active completed).map { |status| statuses[status] })
    end
  end

  private

  def document_is_released_for_delivery
    unless document.released_for_delivery?
      self.errors[:document] << 'darf nicht versendet werden.'
    end
  end

  def check_if_aborted
    unless aborted?
      self.errors[:base] << 'Nur abgebrochene Versendungen können gelöscht werden.'
      false
    end
  end
end
