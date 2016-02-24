describe PrintJobsController do
  describe 'GET index' do
    it 'assigns print_jobs by fax number' do
      pending
      fax_number = '0295235423434'
      print_job = create(:print_job, fax_number: fax_number)
      other_print_job = create(:print_job)
      get :index, fax_number: fax_number
      expect(assigns(:print_jobs)).to eq [print_job]
    end

    it 'assigns only today updated print_jobs' do
      skip
      allow(PrintJob).to receive(:updated_today)
      get :index
      expect(PrintJob).to have_received(:updated_today)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'redirects to print_jobs'
      it 'returns successfully created'
      it 'saves print_job'
    end

    context 'with invalid params' do
      it 'renders new template' do
        post :create, print_job: attributes_for(:print_job, title: nil)
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    it 'sends the pdf document' do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      allow(controller).to receive(:render)

      print_job = create(:print_job)
      expect(controller).to receive(:send_file).
        with(print_job.document.path, type: 'application/pdf')
      get :show, id: print_job
    end
  end

  describe 'DELETE #destroy' do
    let(:print_job) { double(:print_job) }

    before do
      allow(PrintJob).to receive(:find)
      allow(print_job).to receive(:destroy)
    end

    def do_delete
      delete :destroy, id: '42'
    end

    it 'loads print_job' do
      do_delete
      expect(PrintJob).to have_received(:find).with('42')
    end

    context 'when print_job present' do
      before do
        allow(PrintJob).to receive(:find).and_return(print_job)
      end

      it 'destroys print_job' do
        do_delete
        expect(print_job).to have_received(:destroy)
      end

      it 'redirect to aborted print_jobs' do
        do_delete
        expect(response).to redirect_to(aborted_print_jobs_path)
      end
    end

    context 'when print_job missing' do
      before do
        allow(PrintJob).to receive(:find).and_return(nil)
      end

      it 'does not destroy print_job' do
        do_delete
        expect(print_job).not_to have_received(:destroy)
      end

      it 'redirect to aborted print_jobs' do
        do_delete
        expect(response).to redirect_to(aborted_print_jobs_path)
      end
    end
  end
end
