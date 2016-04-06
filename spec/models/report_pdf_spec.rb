describe ReportPdf do
  let(:report)     { build(:report) }
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

    it 'includes subject' do
      allow(report).to receive(:subject).and_return('MRT des Kopfes vom 1.1.1970')
      expect(report_pdf_strings).to include('MRT des Kopfes vom 1.1.1970')
    end

    %i(anamnesis findings evaluation procedure clinic).each do |method|
      it "includes report #{method}" do
        expect(report_pdf_strings).to include(Report.human_attribute_name(method) + ':')
        expect(report_pdf_strings.join(' ')).to include(report.send(method).gsub("\n", ' '))
      end
    end

    %i(diagnosis).each do |method|
      it "excludes report #{method}" do
        expect(report_pdf_strings).not_to include(Report.human_attribute_name(method) + ':')
        expect(report_pdf_strings.join(' ')).not_to include(report.send(method).gsub("\n", ' '))
      end
    end

    context 'with pending report' do
      it 'includes watermark'
      it 'include no signature'
    end

    context 'with verified report' do
      it 'includes no watermark'
      it 'includes signature'
    end
  end
end
