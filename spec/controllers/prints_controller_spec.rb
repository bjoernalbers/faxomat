describe PrintsController do
  describe 'GET index' do
    it 'assigns prints by fax number' do
      pending
      fax_number = '0295235423434'
      print = create(:print, fax_number: fax_number)
      other_print = create(:print)
      get :index, fax_number: fax_number
      expect(assigns(:prints)).to eq [print]
    end

    it 'assigns only today updated prints' do
      skip
      allow(Print).to receive(:updated_today)
      get :index
      expect(Print).to have_received(:updated_today)
    end
  end

  describe 'POST #create' do
    def do_post
      post :create, print: params
    end

    context 'with valid params' do
      let!(:document) { create(:document) }
      let!(:printer) { create(:printer) }
      let(:params) { { 'printer_id' => printer.id, 'document_id' => document.id } }

      it 'creates print' do
        expect { do_post }.to change(Print, :count).by(1)
      end

      it 'redirects to document' do
        do_post
        expect(response).to redirect_to document_path(Document.last)
      end
    end

    context 'with invalid params' do
      it 'renders new template' do
        post :create, print: attributes_for(:print, document: nil)
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    it 'sends document' do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      allow(controller).to receive(:render)

      print = create(:print)
      expect(controller).to receive(:send_file).
        with(print.path, type: 'application/pdf')
      get :show, id: print
    end
  end

  describe 'DELETE #destroy' do
    let(:print) { double(:print) }

    before do
      allow(Print).to receive(:find)
      allow(print).to receive(:destroy)
    end

    def do_delete
      delete :destroy, id: '42'
    end

    it 'loads print' do
      do_delete
      expect(Print).to have_received(:find).with('42')
    end

    context 'when print present' do
      before do
        allow(Print).to receive(:find).and_return(print)
      end

      it 'destroys print' do
        do_delete
        expect(print).to have_received(:destroy)
      end

      it 'redirect to aborted prints' do
        do_delete
        expect(response).to redirect_to(aborted_prints_path)
      end
    end

    context 'when print missing' do
      before do
        allow(Print).to receive(:find).and_return(nil)
      end

      it 'does not destroy print' do
        do_delete
        expect(print).not_to have_received(:destroy)
      end

      it 'redirect to aborted prints' do
        do_delete
        expect(response).to redirect_to(aborted_prints_path)
      end
    end
  end
end
