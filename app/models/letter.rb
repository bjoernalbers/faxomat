class Letter < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :report_id, uniqueness: true

  validate :report_must_be_verified, on: :create

  has_attached_file :document,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_attachment :document,
    content_type: { content_type: 'application/pdf' }

  before_create :assign_document
  after_create :delete_temp_report_pdf

  private

  def report_must_be_verified
    if report.present? && !report.verified?
      errors.add(:report, 'ist noch nicht vidiert')
    end
  end

  def assign_document
    self.document = temp_report_pdf if report.present?
    true
  end

  # TODO: Test this!
  def delete_temp_report_pdf
    @temp_report_pdf.close! if @temp_report_pdf
    true
  end

  # TODO: Test this!
  def temp_report_pdf
    unless @temp_report_pdf
      tmpdir  = Rails.root.join('tmp')
      tmpfile = %w(faxomat .pdf) # Prefix and suffix for temp filename.

      # NOTE: This would return a File instead of of Tempfile (due to re-opening it).
      #Tempfile.open tmpfile, tmpdir, binmode: true do |file|
        #file.write rendered_report_pdf
        #file
      #end.open

      @temp_report_pdf = Tempfile.open tmpfile, tmpdir, binmode: true
      @temp_report_pdf.write rendered_report_pdf
      @temp_report_pdf.flush
      @temp_report_pdf.rewind
      @temp_report_pdf
    else
      @temp_report_pdf
    end
  end

  # TODO: Test this!
  def rendered_report_pdf
    ReportPdf.new(ReportPresenter.new(report, ActionView::Base.new)).render
  end
end
