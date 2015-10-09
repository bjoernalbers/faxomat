describe ReportFaxer do
  let(:report) { double('report') }
  let(:report_faxer) { ReportFaxer.new(report) }

  describe '.deliver' do
    it 'delivers report as fax' do
      report = double('Report.new')
      report_faxer = double('ReportFaxer.new')
      allow(report_faxer).to receive(:deliver)
      allow(ReportFaxer).to receive(:new).and_return(report_faxer)

      ReportFaxer.deliver(report)

      expect(ReportFaxer).to have_received(:new).with(report)
      expect(report_faxer).to have_received(:deliver)
    end
  end

  describe '#deliver' do
    let(:fax) { double('fax') }
    let(:report_pdf_file) { double('report_pdf_file') }

    before do
      allow(fax).to receive(:deliver)
      allow(Fax).to receive(:create).and_return(fax)
      allow(report_pdf_file).to receive(:close!)

      allow(report_faxer).to receive(:report_title).and_return('chunky bacon')
      allow(report_faxer).to receive(:recipient_fax_number).and_return('0123456789')
      allow(report_faxer).to receive(:report_pdf_file).and_return(report_pdf_file)
      allow(report_faxer).to receive(:report_approved?).and_return(true)
    end

    it 'fails without approved report' do
      allow(report_faxer).to receive(:report_approved?).and_return(false)
      expect { report_faxer.deliver }.to raise_error /not approved/
      #report_faxer.deliver
    end

    it 'creates fax from report' do
      report_faxer.deliver
      expect(Fax).to have_received(:create).with(
        title: 'chunky bacon', phone: '0123456789', document: report_pdf_file)
    end

    it 'delivers fax' do
      report_faxer.deliver
      expect(fax).to have_received(:deliver)
    end

    it 'deletes report_pdf_file' do
      report_faxer.deliver
      expect(report_pdf_file).to have_received(:close!)
    end
  end

  describe '#report_title' do
    it 'returns report patient as string' do
      allow(report).to receive(:title).and_return('chunky bacon')
      expect(report_faxer.report_title).to eq('chunky bacon')
    end
  end

  describe '#recipient_fax_number' do
    it 'returns recipient fax number as string' do
      allow(report).to receive(:recipient).
        and_return double(fax_number_string: '0123456789')
      expect(report_faxer.recipient_fax_number).to eq '0123456789'
    end
  end

  describe '#report_pdf_file' do
    before do
      allow(report_faxer).to receive(:rendered_report_pdf).and_return('%PDF')
    end

    after do
      report_faxer.report_pdf_file.close!
    end

    it 'creates temp file' do
      tempfile = Tempfile.new('tempfile')
      allow(Tempfile).to receive(:new).and_return(tempfile)

      report_faxer.report_pdf_file

      expect(Tempfile).to have_received(:new).
        with %w(faxomat .pdf), Rails.root.join('tmp'), binmode: true
    end

    it 'is not closed' do
      expect(report_faxer.report_pdf_file).not_to be_closed
    end

    it 'is stored under Rails root' do
      expect(report_faxer.report_pdf_file.path).to match %r{^#{Rails.root}}
    end

    it 'contains the rendered report pdf' do
      content = report_faxer.report_pdf_file.read
      expect(content).to eq '%PDF'
    end
  end

  describe '#report_approved?' do
    it 'checks if report is approved' do
      allow(report).to receive(:approved?).and_return(:absolutely)
      expect(report_faxer.send(:report_approved?)).to eq :absolutely
      expect(report).to have_received(:approved?)
    end
  end
end