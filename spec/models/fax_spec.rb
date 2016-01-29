describe Fax do
  let(:fax) { build(:fax) }

  it 'has a factory with attached document' do
    expect(fax.document.path).to_not be_nil
  end

  it 'has factory for completed faxes' do
    expect(create(:completed_fax)).to be_completed
  end

  it { expect(fax).to belong_to(:report) }

  describe '.count_by_status' do
    it 'returns number of faxes by status' do
      2.times { create(:active_fax) }
      1.times { create(:aborted_fax) }
      0.times { create(:completed_fax) }

      expect(Fax.count_by_status[:active]).to eq 2
      expect(Fax.count_by_status[:aborted]).to eq 1
      expect(Fax.count_by_status[:completed]).to eq 0
    end
  end

  it 'does not store documents under a public available location' do
    File.open(Rails.root.join('spec', 'support', 'sample.pdf')) do |doc|
      fax.document = doc
      fax.save!
    end
    expect(fax.document.path).to_not match /public/i
  end

  it 'has many print_jobs' do
    print_job = create(:print_job, fax: fax)
    expect(fax.print_jobs).to match_array [print_job]
  end

  it 'destroy dependent print_jobs' do
    print_job = create(:print_job, fax: fax)
    expect(fax.print_jobs).to match_array [print_job]
    fax.destroy
    expect(fax.print_jobs).to be_empty
  end

  describe '#path' do
    it 'returns the document path' do
      expect(fax.path).to eq(fax.document.path)
    end
  end

  context 'without fax_number' do
    let(:phone) { '01230123' }
    let(:fax) { build(:fax, fax_number: nil, phone: phone) }

    it 'creates and assigns a new fax_number by phone' do
      expect{fax.save}.to change(FaxNumber, :count).by 1
      expect(fax.fax_number).to eq FaxNumber.find_by(phone: phone)
    end

    it 'finds and assigns an existing fax_number by phone' do
      create(:fax_number, phone: phone)
      expect{fax.save}.to change(FaxNumber, :count).by 0
      expect(fax.fax_number).to eq FaxNumber.find_by(phone: phone)
    end
  end

  it 'validates the presence of phone' do
    fax = build(:fax, fax_number: nil, phone: nil)
    expect(fax).to be_invalid
    expect(fax.errors[:phone]).to_not be_empty
  end

  it 'validates the presence of a document' do
    fax = build(:fax, document: nil)
    expect(fax).to_not be_valid
    expect(fax.errors[:document].size).to eq(1)
  end

  it 'cleans the phone number from non-digits before save' do
    fax = create(:fax, phone: ' 0123-456 789 ')
    expect(fax.phone).to eq '0123456789'
  end

  it 'is invalid with too short phone' do
    fax = build(:fax, phone: '0123456')
    fax.valid?
    expect(fax.errors[:phone].size).to eq 1
  end

  it 'is invalid when phone has no leading zero' do
    fax = build(:fax, phone: '123456789')
    fax.valid?
    expect(fax.errors[:phone].size).to eq 1
    expect(fax.errors[:phone]).to include('has no area code')
  end

  it 'is invalid when phone has more then one leading zero' do
    fax = build(:fax, phone: '00123456789')
    fax.valid?
    expect(fax.errors[:phone].size).to eq 1
    expect(fax.errors[:phone]).to include('has no area code')
  end

  context 'without a fax_number' do
    let(:fax) { build(:fax, fax_number: nil) }

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  describe '.updated_today' do
    let(:now) { DateTime.current }

    it 'returns today updated faxes' do
      fax = create(:fax, updated_at: now.beginning_of_day)
      expect(Fax.updated_today).to include(fax)
    end

    it 'does not return faxes updated before today' do
      fax = create(:fax, updated_at: now.beginning_of_day-1.second)
      expect(Fax.updated_today).to_not include(fax)
    end
  end

  describe '.created_last_week' do
    let(:now) { Time.zone.local(2015, 1, 13, 20, 59, 59) }
    let(:monday_morning_last_week) { Time.zone.local(2015, 1, 5, 0, 0, 0) }
    let(:sunday_night_last_week) { Time.zone.local(2015, 1, 11, 23, 59, 59) }

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    it 'includes fax from monday morning last week' do
      fax = create(:fax, created_at: monday_morning_last_week)
      expect(Fax.created_last_week).to include fax
    end

    it 'includes fax from sunday night last week' do
      fax = create(:fax, created_at: sunday_night_last_week)
      expect(Fax.created_last_week).to include fax
    end

    it 'excludes fax before monday morning last week' do
      fax = create(:fax, created_at: monday_morning_last_week - 1.second)
      expect(Fax.created_last_week).not_to include fax
    end

    it 'excludes fax after sunday night last week' do
      fax = create(:fax, created_at: sunday_night_last_week + 1.second)
      expect(Fax.created_last_week).not_to include fax
    end
  end

  describe '.check' do
    it 'updates active print jobs' do
      allow(PrintJob).to receive(:update_active)
      Fax.check
      expect(PrintJob).to have_received(:update_active)
    end
  end

  describe '.search' do
    let!(:other_fax) { create(:fax, title: 'another fax') }
    let!(:fax) { create(:fax, title: 'Chunky Bacon') }

    it 'searches by matching title' do
      query = {title: 'Chunky Bacon'}
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches case-insensitive' do
      query = {title: 'chunky bacon'}
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches by title fragment' do
      query = {title: 'unk'}
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches for all query words' do
      skip
      query = {title: 'Bacon Chunky'}
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'handles german umlauts' do
      fax = create(:fax, title: 'Björn')
      query = {title: 'Björn'}
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches for the document name'

    it 'searches by phone' do
      fax = create(:fax, phone: '042424242')
      query = {phone: fax.phone}
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(Fax.search(title: query)).to be_empty
      end
    end
  end

  describe '#phone' do
    let(:phone) { '01234754' }

    it 'returns @phone when set' do
      fax = build(:fax, phone: phone, fax_number: nil)
      expect(fax.phone).to eq phone
    end

    it 'returns fax_number.phone when @phone is not set' do
      fax_number = build(:fax_number, phone: '09823121')
      fax = build(:fax, phone: nil, fax_number: fax_number)
      expect(fax.phone).to eq fax_number.phone
    end

    it 'returns nil when @phone and fax_number are not set' do
      fax = build(:fax, phone: nil, fax_number: nil)
      expect(fax.phone).to be_nil
    end
  end

  context 'without title' do
    let(:fax) { build(:fax, title: nil) }

    it 'is not valid' do
      expect(fax).not_to be_valid
      expect(fax.errors[:title]).not_to be_empty
    end

    it 'is not storable' do
      expect{ fax.save!(validate: false) }.to raise_error
    end
  end

  describe '#deliver' do
    let(:printer) { double(:printer) }

    before do
      allow(Printer).to receive(:new).and_return(printer)
      allow(printer).to receive(:print)
    end

    it 'prints itself' do
      fax.deliver
      expect(printer).to have_received(:print).with(fax)
    end
  end

  describe '#document' do
    it 'allows to attach documents' do
      filename = File.join(File.dirname(__FILE__), '..', 'support', 'sample.pdf')
      file = File.open(filename)
        fax.document = file
        fax.save!
      file.close
    end
  end

  describe '#to_s' do
    it 'returns the fax title' do
      allow(fax).to receive(:title) { 'an awesome fax' }
      expect(fax.to_s).to eq(fax.title)
    end
  end

  describe '#status' do
    context 'is nil' do
      it 'without print jobs' do
        expect(fax.print_jobs).to be_empty
        expect(fax.status).to be nil
      end

      it 'by default' do
        expect(fax.status).to be nil
      end
    end

    context 'is active' do
      it 'with active print job(s)' do
        create(:active_print_job, fax: fax)
        expect(fax).to be_active
      end

      it 'with completed, aborted and active print jobs' do
        create(:completed_print_job, fax: fax)
        create(:aborted_print_job, fax: fax)
        create(:active_print_job, fax: fax)
        expect(fax).to be_active
      end

      it 'by factory :active_fax' do
        fax = create(:active_fax)
        expect(fax).to be_active
      end
    end

    context 'is completed' do
      it 'with completed print job(s)' do
        create(:completed_print_job, fax: fax)
        expect(fax).to be_completed
      end

      it 'with completed and aborted print jobs' do
        create(:completed_print_job, fax: fax)
        create(:aborted_print_job, fax: fax)
        expect(fax).to be_completed
      end
    end

    context 'is aborted' do
      it 'with aborted print job(s)' do
        create(:aborted_print_job, fax: fax)
        expect(fax).to be_aborted
      end

      it 'by factory :aborted_fax' do
        fax = create(:aborted_fax)
        expect(fax).to be_aborted
      end
    end
  end

  describe '#destroy' do
    let(:message) { 'Can only delete aborted faxes.' }

    it 'destroys aborted fax' do
      fax = create(:aborted_fax)
      fax.destroy
      expect(fax).to be_destroyed
    end

    it 'does not destroy completed fax' do
      fax = create(:completed_fax)
      fax.destroy
      expect(fax).not_to be_destroyed
      expect(fax.errors[:base]).to include(message)
    end
    
    it 'does not destroy active fax' do
      fax = create(:active_fax)
      fax.destroy
      expect(fax).not_to be_destroyed
      expect(fax.errors[:base]).to include(message)
    end

    it 'does not destroy unsend fax' do
      fax = create(:fax)
      fax.destroy
      expect(fax).not_to be_destroyed
      expect(fax.errors[:base]).to include(message)
    end
  end
end
