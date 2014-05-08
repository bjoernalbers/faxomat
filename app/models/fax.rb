class Fax < ActiveRecord::Base
  belongs_to :recipient
  belongs_to :patient

  has_many :deliveries

  validates :path, presence: true
  validates :recipient, presence: true
  validates :patient, presence: true

  def status
    if verified?
      success? ? :completed : :aborted
    end
  end

  def verified?
    # TODO: Add implementation!
  end

  # @returns [String] recipient phone number
  def phone
    recipient.phone
  end

  # @returns [String] fax title
  def title
    patient.info
  end

  # Deliver the fax
  def deliver!
    deliveries.create!
  end
end
