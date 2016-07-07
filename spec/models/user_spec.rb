describe User do
  let(:user) { build(:user) }

  %i(username first_name last_name).each do |attr|
    it { expect(user).to validate_presence_of(attr) }
  end

  it { expect(user).not_to validate_presence_of(:title) }

  it { expect(user).to validate_uniqueness_of(:username) }

  it { expect(user).to have_many(:reports) }

  it { expect(user).to have_attached_file(:signature) }
  it { expect(user).to validate_attachment_content_type(:signature).
        allowing('image/png', 'image/jpg', 'image/jpeg').
        rejecting('image/tiff', 'text/plain', 'image/gif', 'text/xml') }
  it { expect(user).to validate_attachment_size(:signature).
                   less_than(30.kilobytes) }

  # TODO: Fix this!
  it 'does not store signatures under a public available location' do
    File.open(Rails.root.join('spec', 'support', 'signature.png')) do |img|
      user.signature = img
      user.save!
    end
    expect(user.signature.path).to_not match /public/i
  end

  describe '#full_name' do
    it 'joins title, first and last name' do
      user = build(:user,
                   title:      'Dr.',
                   first_name: 'Julius M.',
                   last_name:  'Hibbert')
      expect(user.full_name).to eq 'Dr. Julius M. Hibbert'
    end

    it 'excludes blank elements' do
      user = build(:user,
                   title:      'Dr.',
                   first_name: '',
                   last_name:  'Hibbert')
      expect(user.full_name).to eq 'Dr. Hibbert'
    end
  end

  describe '#name' do
    context 'with first name, last name and title' do
      let(:user) { build(:user,
                         first_name: 'Chuck',
                         last_name:  'Norris',
                         title:      'Mr.') }

      it 'returns full name' do
        expect(user.name).to eq 'Mr. Chuck Norris'
      end
    end

    context 'with only last name' do
      let(:user) { build(:user,
                         first_name: nil,
                         last_name:  'Norris',
                         title:      nil) }

      it 'returns last name' do
        expect(user.name).to eq 'Norris'
      end
    end

    context 'without first name, last name and title' do
      let(:user) { build(:user,
                         username:   'chucknorris',
                         first_name: nil,
                         last_name:  nil,
                         title:      nil) }

      it 'returns username' do
        expect(user.name).to eq 'chucknorris'
      end
    end
  end

  describe '#signature_path' do
    context 'with signature' do
      before do
        allow(user).to receive(:signature).
          and_return double(present?: true, path: 'chunky/bacon.png')
      end

      it 'returns signature path' do
        expect(user.signature_path).to eq 'chunky/bacon.png'
      end
    end

    context 'without signature' do
      before do
        allow(user).to receive(:signature).
          and_return double(present?: false)
      end

      it 'returns nil' do
        expect(user.signature_path).to be nil
      end
    end
  end
end
