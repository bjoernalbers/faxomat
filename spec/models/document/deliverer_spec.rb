describe Document::Deliverer do
  let(:recipient) { create(:recipient) }
  let!(:document)  { create(:document, recipient: recipient) }
  let(:subject)   { described_class.new(document) }

  describe '#deliver' do
    let!(:fax_printer)   { create(:fax_printer) }
    let!(:paper_printer) { create(:paper_printer) }

    context 'with recipient fax number' do
      let(:recipient) { create(:recipient) }

      it 'creates fax job' do
        expect { subject.deliver }.to change(PrintJob, :count).by(1)
        print_job = PrintJob.last
        expect(print_job.printer).to eq fax_printer
        expect(print_job.fax_number).to eq recipient.fax_number
      end
    end

    context 'without fax number' do
      let(:recipient) { create(:recipient, fax_number: nil) }

      it 'creates print job' do
        expect { subject.deliver }.to change(PrintJob, :count).by(1)
        print_job = PrintJob.last
        expect(print_job.printer).to eq paper_printer
        expect(print_job.fax_number).to be nil
      end
    end
  end
end
