class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true

  has_many :documents, dependent: :destroy
  has_many :prints, through: :documents
  has_one  :release
  has_many :signings

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date
  validate :check_if_updatable, on: :update

  before_save :replace_carriage_returns
  before_destroy :check_if_destroyable

  #after_update :update_documents, if: :changed?
  after_commit :update_documents, on: :update # TODO: Test this!

  class << self
    def pending
      where.not(id: self::Release.select(:report_id))
    end

    def verified
      where(id: self::Release.uncanceled.select(:report_id))
    end

    def canceled
      where(id: self::Release.canceled.select(:report_id))
    end

    def not_verified
      where.not(id: self::Release.uncanceled.select(:report_id))
    end

    def unreleased
      pending.signed
    end

    def signed
      where(id: self::Signing.select(:report_id))
    end

    def unsigned
      where.not(id: self::Signing.select(:report_id))
    end
  end

  def status
    if release.present?
      release.canceled? ? :canceled : :verified
    else
      :pending
    end
  end

  def verify!
    self.class::Verification.new(report: self, user: user).save
  end

  def cancel!
    release.cancel! if release.present?
  end

  %i(pending verified canceled).each do |method_name|
    define_method("#{method_name}?") do
      status == method_name
    end
  end
  alias_method :include_signature?, :verified?

  def updatable?
    unsigned? && pending?
  end
  alias_method :deletable?, :updatable?

  def signed?
    signings.exists?
  end

  def signed_by?(user)
    signings.exists?(user: user)
  end

  def unsigned?
    !signed?
  end

  def subject
    "#{study} vom #{study_date.strftime('%-d.%-m.%Y')} um #{study_date.strftime('%H:%M')} Uhr"
  end

  def title
    patient.display_name
  end

  def patient_name
    patient.try(:display_name)
  end

  def report_date
    created_at.strftime('%-d.%-m.%Y') if created_at
  end

  def valediction
    'Mit freundlichen Grüßen'
  end

  def physician_name
    user.try(:full_name)
  end

  def physician_suffix
    user.try(:suffix)
  end

  def to_pdf
    ReportPdf.new(self)
  end

  def update_documents
    #documents.each { |document| document.save } # `documents.each` does not work!
    documents.find_each { |document| document.save }
  end

  def cancelable_by?(user)
    verified? && self[:user_id] == user.id
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
    unless deletable?
      errors.add(:base, 'Bericht darf nicht mehr gelöscht werden!')
      false
    end
  end

  def check_if_updatable
    unless updatable?
      errors.add(:base, 'Bericht darf nicht mehr verändert werden!')
      false
    end
  end
end
