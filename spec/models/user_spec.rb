describe User do
  let(:user) { build(:user) }

  it { expect(user).to validate_presence_of(:username) }
  it { expect(user).to validate_uniqueness_of(:username) }
  it { expect(user).not_to validate_presence_of(:first_name) }
  it { expect(user).not_to validate_presence_of(:last_name) }
  it { expect(user).not_to validate_presence_of(:title) }

  it { expect(user).to have_many(:reports) }

  describe '#full_name' do
    it 'joins title, first and last name' do
      user = build(:user,
                   title:      'Dr.',
                   first_name: 'Julius M.',
                   last_name:  'Hibbert')
      expect(user.full_name).to eq 'Dr. Julius M. Hibbert'
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
end
