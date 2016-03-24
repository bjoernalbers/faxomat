class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true
  has_many :print_jobs

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date

  scope :pending,  -> { where(verified_at: nil).where(canceled_at: nil) }
  scope :verified, -> { where.not(verified_at: nil).where(canceled_at: nil) }
  scope :undelivered, -> { verified.without_completed_print_job.without_active_print_job }
  # Taken from: http://stackoverflow.com/questions/5319400/want-to-find-records-with-no-associated-records-in-rails-3
  scope :without_completed_print_job, -> { where.not(id: PrintJob.completed.select(:report_id)) }
  scope :without_active_print_job, -> { where.not(id: PrintJob.active.select(:report_id)) }

  before_save :replace_carriage_returns
  before_destroy :check_if_destroyable
  before_update :check_if_updatable

  def status
    if canceled_at.present?
      :canceled
    elsif verified_at.present?
      :verified
    else
      :pending
    end
  end

  def status=(attr)
    case attr.to_sym
    when :verified
      self.verified_at = Time.zone.now if pending?
    when :canceled
      self.canceled_at = Time.zone.now if verified?
    end
  end

  %i(pending verified canceled).each do |method_name|
    define_method("#{method_name}?") do
      status == method_name
    end
  end
  alias_method :deletable?, :pending?

  def subject
    "#{study} vom #{study_date.strftime('%-d.%-m.%Y')}"
  end

  def title
    patient.display_name
  end

  def deliver_as_fax
    if printer = FaxPrinter.default
      if recipient_fax_number.present? # TODO: Move this into Printing-model!
        Report::Printing.new(report: self, printer: printer).save
      else
        false
      end
    else
      false
    end
  end

  def undelivered?
    print_jobs.completed.empty? && print_jobs.active.empty?
  end

  def recipient_fax_number
    recipient.try(:fax_number)
  end

  private

  # NOTE: Tomedo somehow sends both carriage return and newlines. We're
  # replacing all carriage returns with new lines since they look weird in PDF
  # documents.
  def replace_carriage_returns
    %i(anamnesis diagnosis findings evaluation procedure).each do |attr|
      self[attr].gsub!("\r", "\n") if self[attr].present?
    end
  end

  def check_if_destroyable
    unless pending?
      errors.add(:base, 'Arztbrief darf nicht mehr gelöscht werden!')
      false
    end
  end

  def check_if_updatable
    unless pending? || only_status_changed?
      errors.add(:base, 'Arztbrief darf nicht mehr verändert werden!')
      false
    end
  end

  def only_status_changed?
    changed.all? { |c| %w(verified_at canceled_at updated_at).include?(c) }
  end
end
