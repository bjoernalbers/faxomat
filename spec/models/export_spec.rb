describe Export do
  subject { build(:export) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Export'
  end

  it_behaves_like 'a deliverable'

  describe '#directory' do
    it 'must be present' do
      subject.directory = nil
      expect(subject).to be_invalid
      expect(subject.errors[:directory]).to be_present
    end

    it 'must be present in database' do
      subject.save
      expect {
        subject.update_column(:directory_id, nil)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'is translated' do
      expect(described_class.human_attribute_name(:directory)).
        to eq 'Ordner'
    end
  end

  describe '#filename' do
    context 'when present on save' do
      subject { build(:export, filename: 'chunky_bacon.pdf') }

      before do
        subject.save
      end

      it 'does not get overwritten' do
        expect(subject.filename).to eq 'chunky_bacon.pdf'
      end
    end

    context 'when missing on save' do
      let(:filename) { double(:filename) }
      subject { build(:export, filename: nil) }

      before do
        allow(Export::Filename).to receive(:new) { filename }
        allow(filename).to receive(:to_s) { 'bacon_is_chunky.pdf' }
        subject.save
      end

      it 'gets assigned' do
        expect(Export::Filename).to have_received(:new).with(subject.document)
        expect(filename).to have_received(:to_s)
        expect(subject.filename).to eq 'bacon_is_chunky.pdf'
      end
    end

    it 'must be present in database' do
      subject.save
      expect {
        subject.update_column(:filename, nil)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'is translated' do
      expect(described_class.human_attribute_name(:filename)).
        to eq 'Dateiname'
    end
  end

  describe '#source' do
    let(:document) { build(:document) }
    subject { build(:export, document: document) }

    it 'returns document path as Pathname' do
      source = Pathname.new(document.path)
      expect(subject.source).to eq source
    end
  end

  describe '#destination' do
    let(:directory) { build(:directory, path: '/tmp') }
    subject { build(:export, directory: directory) }

    it 'returns directory path with filename as Pathname' do
      subject.filename = 'chunky_bacon.pdf'
      destination = Pathname.new('/tmp/chunky_bacon.pdf')
      expect(subject.destination).to eq destination
    end
  end

  describe '#save' do
    context 'when #copy_file returns false' do
      before do
        allow(subject).to receive(:copy_file) { false }
      end

      it 'does not create record' do
        expect{ subject.save }.not_to change(described_class, :count)
      end
    end

    context 'when #copy_file returns true' do
      before do
        allow(subject).to receive(:copy_file) { true }
      end

      it 'creates record' do
        expect{ subject.save }.to change(described_class, :count).by(1)
      end
    end

    context 'on update' do
      subject { create(:export) }

      before do
        allow(subject).to receive(:copy_file) { true }
      end

      it 'does not run #copy_file' do
        subject.save
        expect(subject).not_to have_received(:copy_file)
      end
    end
  end

  describe '#destroy' do
    subject { create(:export) }

    context 'when destination present' do
      it 'deletes destination' do
        subject.destroy
        expect(subject.destination).not_to be_exist
      end

      it 'removes record' do
        subject.destroy
        expect(subject).not_to be_persisted
      end
    end

    context 'when destination missing' do
      before do
        subject.destination.delete
      end

      it 'ignores destination when missing' do
        expect {
          subject.destroy
        }.not_to raise_error(StandardError)
      end

      it 'removes record' do
        subject.destroy
        expect(subject).not_to be_persisted
      end
    end
  end

  ### Private methods below!!! ###

  describe '#copy_file!' do
    before do
      allow(FileUtils).to receive(:cp)
      allow(subject).to receive(:source) { '/tmp/foo.pdf' }
      allow(subject).to receive(:destination) { '/tmp/bar.pdf' }
    end

    it 'copies source to destination' do
      subject.send(:copy_file!)
      expect(FileUtils).to have_received(:cp).
        with('/tmp/foo.pdf', '/tmp/bar.pdf')
    end
  end

  describe '#copy_file' do
    context 'without exception' do
      before do
        allow(subject).to receive(:copy_file!)
      end

      it 'returns true' do
        expect(subject.send(:copy_file)).to eq true
      end
    end

    context 'with Errno::* exception' do
      let(:msg) { 'No such file or directory - chunky_bacon.pdf' }
      before do
        allow(subject).to receive(:copy_file!) do
          raise Errno::ENOENT, msg
        end
      end

      it 'adds error message' do
        subject.send(:copy_file)
        expect(subject.errors[:base].join).to include(msg)
      end

      it 'returns false' do
        expect(subject.send(:copy_file)).to eq false
      end
    end

    context 'with other exception' do
      before do
        allow(subject).to receive(:copy_file!) do
          raise ArgumentError, 'Oh, shit!'
        end
      end

      it 'does not rescue' do
        expect {
          subject.send(:copy_file)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#with_retry' do
    let(:retryable) { double(:retryable) }

    before do
      allow(subject).to receive(:sleep)
    end

    def run_with_retry
      subject.send(:with_retry) { retryable.run }
    end

    context 'without exception' do
      before do
        allow(retryable).to receive(:run)
      end

      it 'runs only once' do
        run_with_retry
        expect(retryable).to have_received(:run).once
      end

      it 'does not sleep' do
        run_with_retry
        expect(subject).not_to have_received(:sleep)
      end
    end

    context 'with exception' do
      before do
        allow(retryable).to receive(:run) do
          raise StandardError, 'OMG!'
        end
      end

      it 'retries 3 times' do
        expect {
          run_with_retry
        }.to raise_error(StandardError)
        expect(retryable).to have_received(:run).exactly(3).times
      end

      it 'sleeps 2 times' do
        expect {
          run_with_retry
        }.to raise_error(StandardError)
        expect(subject).to have_received(:sleep).exactly(2).times
      end
    end
  end
end
