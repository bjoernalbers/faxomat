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

  describe '#cups_state' do
    it 'can be present' do
      print_job.cups_state = :chunky_bacon
      expect(print_job.cups_state).to eq :chunky_bacon
    end
  end
end
