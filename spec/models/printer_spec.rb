describe Printer do
  let(:subject) { build(:printer) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_a described_class
    expect(subject.dialout_prefix).not_to be_present
  end

  it { expect(subject).to have_many(:prints) }

  describe '.active' do
    let(:subject) { described_class }
    let(:printer) { create(:printer) }

    it 'includes printer with active print job' do
      create(:active_print, printer: printer)
      expect(subject.active).to include printer
    end

    it 'excludes printer without active print job' do
      create(:completed_print, printer: printer)
      create(:aborted_print, printer: printer)
      expect(subject.active).not_to include printer
    end

    it 'returns distinct printers' do
      create_list(:active_print, 2, printer: printer)
      expect(subject.active.count).to eq 1
    end
  end

  describe '#name' do
    it { expect(subject).to validate_presence_of(:name) }

    it { expect(subject).to validate_uniqueness_of(:name) }

    it 'can not be stored when not unique' do
      subject.name = create(:printer).name
      expect{ subject.save!(validate: false) }.to raise_error
    end
  end

  describe '#label' do
    it { expect(subject).to validate_presence_of(:label) }
  end

  describe '#dialout_prefix' do
    it { expect(subject).not_to validate_presence_of(:dialout_prefix) }
  end
end
