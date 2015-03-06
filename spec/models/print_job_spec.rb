require 'spec_helper'

RSpec.describe PrintJob, :type => :model do
  let(:print_job) { build(:print_job) }

  describe '#fax' do
    it 'must be present' do
      print_job.fax = nil
      expect(print_job).not_to be_valid
      expect{ print_job.save!(validate: false) }.to raise_error
    end
  end

  describe '#cups_id' do
    it 'must be present' do
      print_job.cups_id = nil
      expect(print_job).not_to be_valid
      expect{ print_job.save!(validate: false) }.to raise_error
    end

    it 'must be unique' do
      print_job.cups_id = create(:print_job).cups_id
      expect(print_job).not_to be_valid
      expect{ print_job.save!(validate: false) }.to raise_error
    end
  end

  describe '#cups_status' do
    it 'can be present' do
      print_job.cups_status = :chunky_bacon
      expect(print_job.cups_status).to eq :chunky_bacon
    end
  end

  describe '#status' do
    context 'is active' do
      it 'with cups_status=nil' do
        print_job.update!(cups_status: nil)
        expect(print_job).to be_active
      end

      it 'with cups_status=unknown' do
        print_job.update!(cups_status: :chunky_bacon)
        expect(print_job).to be_active
      end

      it 'by default' do
        expect(PrintJob.new).to be_active
      end
    end

    context 'is completed' do
      it 'with cups_status=completed' do
        print_job.update!(cups_status: 'completed')
        expect(print_job).to be_completed
      end
    end

    context 'is aborted' do
      it 'with cups_status=aborted' do
        print_job.update!(cups_status: 'aborted')
        expect(print_job).to be_aborted
      end

      it 'with cups_status=canceled' do
        print_job.update!(cups_status: 'canceled')
        expect(print_job).to be_aborted
      end
    end
  end
end
