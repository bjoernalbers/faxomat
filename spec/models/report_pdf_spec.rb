describe ReportPdf do
  include ActionView::TestCase::Behavior # Makes `view` available for presenter.

  #let(:report)     { build(:report) }
  let(:report) { ReportPresenter.new(build(:report), view) }
  let(:report_pdf) { ReportPdf.new(report) }

  def report_pdf_strings
    PDF::Inspector::Text.analyze(report_pdf.render).strings
  end

  describe '#render' do
    it 'returns PDF as string' do
      expect(report_pdf.render[0,4]).to eq '%PDF' # Magic number for PDF
    end

    it 'includes subject' do
      expect(report_pdf_strings).to include(report.subject)
    end

    it 'includes patient name' do
      allow(report).to receive(:patient_name).and_return('Norris, Chuck (* 10.3.1940)')
      expect(report_pdf_strings).to include('Norris, Chuck (* 10.3.1940)')
    end

    it 'includes physician name' do
      allow(report).to receive(:physician_name).and_return('Dr. House')
      expect(report_pdf_strings).to include('Dr. House')
    end

    it 'includes recipient address'

    it 'includes salutation' do
      allow(report).to receive(:salutation).and_return('Hallihallo Dr. Hibbert,')
      expect(report_pdf_strings).to include('Hallihallo Dr. Hibbert,')
    end

    it 'includes report date' do
      allow(report).to receive(:report_date).and_return('1. Mai 1970')
      expect(report_pdf_strings).to include('1. Mai 1970')
    end

    %i(examination anamnesis diagnosis findings evaluation procedure clinic).each do |method|
      it "includes report #{method}" do
        expect(report_pdf_strings).to include(Report.human_attribute_name(method) + ':')
        expect(report_pdf_strings.join(' ')).to include(report.send(method).gsub("\n", ' '))
      end
    end

    context 'with pending report' do
      it 'includes watermark'
      it 'include no signature'
    end

    context 'with approved report' do
      it 'includes no watermark'
      it 'includes signature'
    end
  end
end
