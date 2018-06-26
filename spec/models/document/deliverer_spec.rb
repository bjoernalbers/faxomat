describe Document::Deliverer do
  let(:recipient) { create(:recipient) }
  let!(:document)  { create(:document, recipient: recipient) }
  let(:subject)   { described_class.new(document) }

  describe '#deliver' do
    before do
      allow(subject).to receive(:print_document)
      allow(subject).to receive(:export_document)
    end

    it 'prints document' do
      subject.deliver
      expect(subject).to have_received(:print_document)
    end

    context 'when recipient is EVK' do
      before do
        allow(document).to receive(:recipient_is_evk?) { true }
      end

      it 'exports document' do
        subject.deliver
        expect(subject).to have_received(:export_document)
      end
    end

    context 'when recipient is not EVK' do
      before do
        allow(document).to receive(:recipient_is_evk?) { false }
      end

      it 'does not export document' do
        subject.deliver
        expect(subject).not_to have_received(:export_document)
      end
    end

    context 'when printing raises error' do
      let(:logger) { double('logger') }
      let(:error_message) { 'Oops!' }
      before do
        allow(subject).to receive(:print_document) { raise error_message }
        allow(Rails).to receive(:logger) { logger }
        allow(logger).to receive(:error)
      end

      it 'rescues exception' do
        expect { subject.deliver }.not_to raise_error
      end

      it 'logs exception' do
        subject.deliver
        expect(logger).to have_received(:error).with(error_message)
      end
    end
  end

  describe '#print_document' do
    let!(:fax_printer)   { create(:fax_printer) }
    let!(:paper_printer) { create(:paper_printer) }
    let!(:hylafax_printer) { create(:hylafax_printer) }

    context 'with recipient fax number but not hylafax enabled' do
      let(:recipient) { create(:recipient, send_with_hylafax: false) }

      it 'creates CUPS fax job' do
        expect { subject.print_document }.to change(Print, :count).by(1)
        print = Print.last
        expect(print.printer).to eq fax_printer
        expect(print.fax_number).to eq recipient.fax_number
      end
    end

    context 'with recipient fax number and hylafax enabled' do
      let(:recipient) { create(:recipient, send_with_hylafax: true) }

      it 'creates HylaFAX fax job' do
        expect { subject.print_document }.to change(Print, :count).by(1)
        print = Print.last
        expect(print.printer).to eq hylafax_printer
        expect(print.fax_number).to eq recipient.fax_number
      end
    end

    context 'without fax number' do
      let(:recipient) { create(:recipient, fax_number: nil) }

      it 'creates print job' do
        expect { subject.print_document }.to change(Print, :count).by(1)
        print = Print.last
        expect(print.printer).to eq paper_printer
        expect(print.fax_number).to be nil
      end
    end
  end

  describe '#export_document' do
    context 'with default directory' do
      let(:directory) { create(:directory) }

      before do
        allow(Directory).to receive(:default) { directory }
      end

      it 'creates export' do
        expect { subject.export_document }.to change(directory.exports, :count).by(1)
      end
    end

    context 'without default directory' do
      it 'creates no export' do
        expect(Directory.default).to be nil
        expect { subject.export_document }.not_to change(Export, :count)
      end
    end
  end
end
