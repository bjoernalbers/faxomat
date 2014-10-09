require 'spec_helper'

describe Fax do
  let(:fax) { build(:fax) }
  let(:deliverer) { double(:deliverer) }

  before do
    allow(Fax::Deliverer).to receive(:new).and_return(deliverer)
    allow(deliverer).to receive(:deliver)
  end

  it 'has a factory with attached document' do
    expect(fax.document.path).to_not be_nil
  end

  it 'does not store documents under a public available location' do
    File.open(Rails.root.join('spec', 'support', 'sample.pdf')) do |doc|
      fax.document = doc
      fax.save!
    end
    expect(fax.document.path).to_not match /public/i
  end

  context 'when created' do
    before do
      allow(fax).to receive(:deliver)
    end

    it 'gets delivered' do
      expect(fax).to_not have_received(:deliver)
      fax.save
      expect(fax).to have_received(:deliver)
    end
  end

  describe '#path' do
    it 'returns the document path' do
      expect(fax.path).to eq(fax.document.path)
    end
  end

  context 'without recipient' do
    let(:phone) { '01230123' }
    let(:fax) { build(:fax, recipient: nil, phone: phone) }

    it 'creates and assigns a new recipient by phone' do
      expect{fax.save}.to change(Recipient, :count).by 1
      expect(fax.recipient).to eq Recipient.find_by(phone: phone)
    end

    it 'finds and assigns an existing recipient by phone' do
      create(:recipient, phone: phone)
      expect{fax.save}.to change(Recipient, :count).by 0
      expect(fax.recipient).to eq Recipient.find_by(phone: phone)
    end
  end

  it 'validates the presence of phone' do
    fax = build(:fax, recipient: nil, phone: nil)
    expect(fax).to be_invalid
    expect(fax.errors_on(:phone)).to_not be_empty
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
    expect(fax).to have(1).errors_on(:phone)
  end

  it 'is invalid when phone has no leading zero' do
    fax = build(:fax, phone: '123456789')
    expect(fax).to have(1).errors_on(:phone)
    expect(fax.errors_on(:phone)).to include('has no area code')
  end

  it 'is invalid when phone has more then one leading zero' do
    fax = build(:fax, phone: '00123456789')
    expect(fax).to have(1).errors_on(:phone)
    expect(fax.errors_on(:phone)).to include('has no area code')
  end

  context 'without a recipient' do
    let(:fax) { build(:fax, recipient: nil) }

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  context 'with non-unique print_job_id' do
    let(:other_fax) { create(:fax, print_job_id: 5) }
    let(:fax) { build(:fax, print_job_id: other_fax.print_job_id) }

    it 'is invalid' do
      expect(fax).to have(1).errors_on(:print_job_id)
    end

    it 'can not be saved in the database' do
      expect {
        fax.save(validate: false)
      }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  context 'without print_job_id' do
    let(:fax) { build(:fax, print_job_id: nil) }

    it 'is valid' do
      expect(fax).to be_valid
    end

    it 'can be saved in the database' do
      expect {
        fax.save(validate: false)
      }.to_not raise_error ActiveRecord::RecordNotUnique
    end

    it 'can be saved even with other null print_job_ids' do
      2.times {
        expect { create(:fax, print_job_id: nil) }.to_not raise_error
      }
    end
  end

  describe '.created_today' do
    let(:now) { DateTime.current }

    it 'returns today created faxes' do
      fax = create(:fax, created_at: now.beginning_of_day)
      expect(Fax.created_today).to include(fax)
    end

    it 'does not return faxes created before today' do
      fax = create(:fax, created_at: now.beginning_of_day-1.second)
      expect(Fax.created_today).to_not include(fax)
    end
  end

  describe '.deliver' do
    before do
      allow(Fax::Deliverer).to receive(:deliver)
    end

    it 'delivers faxes with the deliverer' do
      expect(Fax::Deliverer).to_not have_received(:deliver)
      Fax.deliver
      expect(Fax::Deliverer).to have_received(:deliver)
    end
  end

  describe '.check' do
    before do
      allow(Fax::Deliverer).to receive(:check)
    end

    it 'checks faxes with the deliverer' do
      expect(Fax::Deliverer).to_not have_received(:check)
      Fax.check
      expect(Fax::Deliverer).to have_received(:check)
    end
  end

  describe '.undeliverable' do
    it 'returns undeliverable' do
      fax.update(state: 'undeliverable')
      expect(Fax.undeliverable).to match_array([fax])
    end

    it 'does not return faxes in other states' do
      create(:fax, state:'completed')
      create(:fax)
      create(:fax, state:'funky')
      expect(Fax.undeliverable).to be_empty
    end
  end

  describe '.search' do
    let!(:other_fax) { create(:fax, title: 'another fax') }
    let!(:fax) { create(:fax, title: 'Chunky Bacon') }

    it 'searches by matching title' do
      query = 'Chunky Bacon'
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches case-insensitive' do
      query = 'chunky bacon'
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches by title fragment' do
      query = 'unk'
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches for all query words' do
      query = 'Bacon Chunky'
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'handles german umlauts' do
      fax = create(:fax, title: 'Björn')
      query = 'Björn'
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches for the document name'

    it 'searches by phone' do
      fax = create(:fax, phone: '042424242')
      query = fax.phone
      expect(Fax.search(query)).to match_array [fax]
    end

    it 'searches by recipient phone number' do
      pending
      expect(Fax.search('8765')).to match_array [fax]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(Fax.search(query)).to be_empty
      end
    end
  end

  describe '#phone' do
    let(:phone) { '01234754' }

    it 'returns @phone when set' do
      fax = build(:fax, phone: phone, recipient: nil)
      expect(fax.phone).to eq phone
    end

    it 'returns recipient.phone when @phone is not set' do
      recipient = build(:recipient, phone: '09823121')
      fax = build(:fax, phone: nil, recipient: recipient)
      expect(fax.phone).to eq recipient.phone
    end

    it 'returns nil when @phone and recipient are not set' do
      fax = build(:fax, phone: nil, recipient: nil)
      expect(fax.phone).to be_nil
    end
  end

  it 'has many deliveries' do
    expect(fax).to respond_to(:deliveries)
  end

  it 'destroys dependend deliveries' do
    fax = create(:fax)
    2.times { create(:delivery, fax: fax) }
    expect(fax.deliveries).to_not be_empty
    fax.destroy
    expect(fax.deliveries).to be_empty
  end

  describe '#title' do
    context 'when set' do
      let(:title) { 'My wonderful fax' }
      let(:fax) { create(:fax, title: title) }

      it 'returns the given value' do
        expect(fax.title).to eq title
      end
    end

    context 'when not set' do
      let(:fax) { create(:fax, title: nil) }

      it 'returns nil' do
        expect(fax.title).to be_nil
      end
    end
  end

  describe '#deliver' do
    before do
      fax.deliver
    end

    it 'creates a new deliverer' do
      expect(Fax::Deliverer).to have_received(:new).with(fax)
    end

    it 'delivers the fax' do
      expect(deliverer).to have_received(:deliver)
    end
  end

  it 'has no delivery attempts when initialized' do
    fax = build(:fax)
    expect(fax.delivery_attempts).to eq nil
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
end
