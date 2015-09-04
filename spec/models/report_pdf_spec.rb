describe ReportPdf do
  let(:report)     { build(:report) }
  let(:report_pdf) { ReportPdf.new(report) }

  describe '#render' do
    it 'returns PDF as string' do
      expect(report_pdf.render[0,4]).to eq '%PDF' # Magic number for PDF
    end

    it 'includes subject' do
      rendered_pdf = report_pdf.render
      text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
      expect(text_analysis.strings).to include(report.subject)
    end

    it 'includes content' do
      report.content = 'chunky bacon'
      rendered_pdf = report_pdf.render
      text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)
      expect(text_analysis.strings).to include('chunky bacon')
    end

    it 'includes patient'

    it 'includes name of doctor'

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
