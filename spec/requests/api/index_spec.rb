describe 'GET /api/faxes' do
  let(:params)  { { } }
  let(:headers) { { 'Accept' => 'application/json' } }

  def do_get
    get '/api/faxes', params, headers
  end

  def json
    @json ||= JSON.parse(response.body)
  end

  context 'without explicit accept header' do
    let(:headers) { { } }

    it 'returns JSON by default' do
      do_get
      expect(response.content_type).to be_json
    end
  end

  it 'returns number of faxes by status' do
    Fax.destroy_all # TODO: Fix database cleaner!
    2.times { FactoryGirl.create(:active_fax) }
    1.times { FactoryGirl.create(:aborted_fax) }
    0.times { FactoryGirl.create(:completed_fax) }
    do_get
    expect(json['active']).to eq 2
    expect(json['aborted']).to eq 1
    expect(json['completed']).to eq 0
  end

  it 'returns number of active faxes' do
    7.times { FactoryGirl.create(:active_fax) }
    do_get
    expect(json['active']).to eq 7
  end

  it 'returns number of aborted faxes'
end
