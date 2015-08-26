describe 'GET /users' do
  let!(:user) { create(:user) }

  def users
    @users ||= JSON.parse(response.body, symbolize_names: true)
  end

  before do
    get '/users', {},
      {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json'
      }
  end

  it 'returns HTTP status 200' do
    expect(response.status).to eq 200
  end

  it 'responds in JSON' do
    expect(response.content_type).to be_json
  end

  it 'returns array of users' do
    expect(users.count).to eq 1
  end

  it 'returns id and name per user' do
    expect(users.count).to eq 1 #debug
    expect(users.first[:id]).to eq user.id
    expect(users.first[:name]).to eq user.name
  end
end
