describe ReportPdf do
  let(:report)    { build(:report) }
  let(:recipient) { build(:recipient) }
  let(:document)  { build(:document, report: report, recipient: recipient) }
  let(:subject)   { ReportPdf.new(document) }

  def report_pdf_strings
    PDF::Inspector::Text.analyze(subject.render).strings
  end

  describe '#render' do
    it 'returns PDF as string' do
      expect(subject.render[0,4]).to eq '%PDF' # Magic number for PDF
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
      allow(recipient).to receive(:salutation).and_return('Hallihallo Dr. Hibbert,')
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

    %w(title subtitle short_title slogan return_address contact_infos owners).each do |text|
      it "includes template #{text}" do
        template = build(:template)
        allow(Template).to receive(:default).and_return(template)
        #expect(report_pdf_strings).to include template.send(text)
        expect(report_pdf_strings.join("\n")).to include template.send(text)
      end
    end

    context 'with pending report' do
      it 'includes watermark'
      it 'include no signature'
    end

    context 'with verified report' do
      let(:report) { create(:verified_report) }

      it 'includes no watermark'
      it 'includes signature'
    end
  end

  describe '#template' do
    it 'returns default template' do
      template = build(:template)
      allow(Template).to receive(:default).and_return(template)
      expect(subject.template).to eq template
    end
  end

  describe '#watermark' do
    it 'with pending report returns "ENTWURF"' do
      document.report = create(:pending_report)
      expect(subject.watermark).to eq 'ENTWURF'
    end

    it 'with verified report returns nil' do
      document.report = create(:verified_report)
      expect(subject.watermark).to be nil
    end

    it 'with canceled report returns "STORNIERT"' do
      document.report = create(:canceled_report)
      expect(subject.watermark).to eq 'STORNIERT'
    end
  end

  describe '#path' do
    before do
      allow(subject).to receive(:filename).and_return('chunky_bacon.pdf')
    end

    it 'joins tmp dir with filename' do
      expect(subject.send(:path)).
        to eq "#{Rails.root.join('tmp')}/chunky_bacon.pdf"
    end
  end

  describe '#filename' do
    it 'begins with human model name' do
      expect(subject.filename).to match %r{^Bericht}
    end

    it 'includes report id' do
      expect(subject.filename).to include report.id.to_s
    end

    it 'includes watermark text' do
      allow(subject).to receive(:watermark).and_return('chunky')
      expect(subject.filename).to include 'chunky'
    end

    it 'ends with pdf' do
      expect(subject.filename).to match /.pdf$/
    end
  end
end
