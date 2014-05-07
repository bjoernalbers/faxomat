class Fax < ActiveRecord::Base
  DIALOUT_PREFIX = '0'

  belongs_to :recipient
  belongs_to :patient

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

  # Deliver the fax via system command.
  def deliver
    # TODO: Store the print job ID on successful delivery, which is required
    # for verification later!
    update(delivered_at: Time.now) if system(command)
  end

  private

  # @returns [String] command-line for CUPS fax-printer
  def command
    "lp -d Fax -o phone=#{phone} '#{path}'"
  end

  # @returns [String] recipients phone number with dialout prefix
  def phone
    DIALOUT_PREFIX + recipient.phone
  end
end
