describe 'GET /api/print_jobs' do
  let(:params)  { { } }
  let(:headers) { { 'Accept' => 'application/json' } }

  def do_get
    get '/api/print_jobs', params, headers
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

  it 'returns number of print jobs by status' do
    pending
    PrintJob.destroy_all # TODO: Fix database cleaner!
    2.times { FactoryGirl.create(:active_print_job) }
    1.times { FactoryGirl.create(:aborted_print_job) }
    0.times { FactoryGirl.create(:completed_print_job) }
    do_get
    expect(json['active']).to eq 2
    expect(json['aborted']).to eq 1
    expect(json['completed']).to eq 0
  end

  it 'returns number of active print jobs' do
    7.times { FactoryGirl.create(:active_print_job) }
    do_get
    expect(json['active']).to eq 7
  end

  it 'returns number of aborted print jobs'
end
