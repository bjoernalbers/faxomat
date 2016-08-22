module Deliverable
  extend ActiveSupport::Concern

  included do
    belongs_to :document, required: true

    validate :document_is_released_for_delivery, if: :document, on: :create
  end

  private

  def document_is_released_for_delivery
    unless document.released_for_delivery?
      self.errors[:document] << 'darf nicht versendet werden.'
    end
  end
end
