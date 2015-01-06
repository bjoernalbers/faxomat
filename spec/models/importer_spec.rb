require 'spec_helper'

describe Importer do
  let(:file) { 'job.json' }
  let(:importer) { Importer.new(file) }

  describe '#run' do
    let(:job) { double('job', save: false) }

    before do
      allow(FileUtils).to receive(:rm)
      allow(importer).to receive(:job).and_return(job)
    end

    it 'deletes the file when job was saved' do
      allow(job).to receive(:save).and_return(true)
      importer.run
      expect(FileUtils).to have_received(:rm).with(file)
    end

    it 'does not delete the file when job was not saved' do
      allow(job).to receive(:save).and_return(false)
      importer.run
      expect(FileUtils).to_not have_received(:rm)
    end
  end

  describe '#job' do
    it 'returns a new job' do
      skip 'replace by fax'
      job = double('job')
      allow(Job).to receive(:new).and_return(job)
      allow(importer).to receive(:clean_attributes).and_return('attributes')
      expect(importer.job).to eq job
      expect(Job).to have_received(:new).with('attributes')
    end
  end

  describe '#clean_attributes' do
    let(:attributes) do
      { 'patient_first_name' => 'Chuck',
        'patient_last_name' => 'Norris',
        'patient_date_of_birth' => '1940-03-10',
        'phone' => '0815',
        'file' => '/tmp/chuck.pdf',
        'type' => 'fax' }
    end

    before do
      allow(importer).to receive(:attributes).and_return(attributes)
    end

    it 'keeps required attributes' do
      cleaned = importer.send(:clean_attributes)
      [ 'patient_first_name',
        'patient_last_name',
        'patient_date_of_birth',
        'phone'].each do |key|
        expect(cleaned).to have_key(key)
      end
    end

    it 'renames "file" to "path"' do
      cleaned = importer.send(:clean_attributes)
      expect(cleaned).to have_key('path')
      expect(cleaned).to_not have_key('file')
    end

    it 'drops unknown attributes' do
      cleaned = importer.send(:clean_attributes)
      expect(cleaned).to_not have_key('type')
    end
  end

  describe '#attributes' do
    it 'returns the parsed JSON' do
      allow(JSON).to receive(:parse)
      allow(importer).to receive(:json).and_return('json')
      importer.send(:attributes)
      expect(JSON).to have_received(:parse).with('json')
    end
  end

  describe '#json' do
    before do
      allow(File).to receive(:read).and_return("Schl\237ter")
    end

    it 'encodes the content from MacRoman to UTF-8' do
      expect(importer.send(:json)).to eq('Schlüter')
    end

    it 'reads the file' do
      importer.send(:json)
      expect(File).to have_received(:read).with(file)
    end
  end
end
