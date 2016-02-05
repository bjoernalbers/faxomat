describe FaxesController do
  describe 'GET index' do
    it 'assigns faxes by fax number' do
      skip
      fax_number = create(:fax_number)
      fax = create(:fax, fax_number: fax_number)
      get :index, fax_number_id: fax_number
      expect(assigns(:faxes)).to eq [fax]
    end

    it 'does not assign faxes to other fax numbers' do
      fax_number = create(:fax_number)
      other_fax_number = create(:fax_number)
      fax = create(:fax, fax_number: other_fax_number)
      get :index, fax_number_id: fax_number
      expect(assigns(:faxes)).to_not include fax
    end

    it 'assigns only today updated faxes' do
      skip
      allow(Fax).to receive(:updated_today)
      get :index
      expect(Fax).to have_received(:updated_today)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'redirects to faxes'
      it 'returns successfully created'
      it 'saves fax'
    end

    context 'with invalid params' do
      it 'renders new template' do
        post :create, fax: attributes_for(:fax, title: nil)
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    it 'sends the pdf document' do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      allow(controller).to receive(:render)

      fax = create(:fax)
      expect(controller).to receive(:send_file).
        with(fax.document.path, type: 'application/pdf')
      get :show, id: fax
    end
  end

  describe 'DELETE #destroy' do
    let(:fax) { double(:fax) }

    before do
      allow(Fax).to receive(:find)
      allow(fax).to receive(:destroy)
    end

    def do_delete
      delete :destroy, id: '42'
    end

    it 'loads fax' do
      do_delete
      expect(Fax).to have_received(:find).with('42')
    end

    context 'when fax present' do
      before do
        allow(Fax).to receive(:find).and_return(fax)
      end

      it 'destroys fax' do
        do_delete
        expect(fax).to have_received(:destroy)
      end

      it 'redirect to aborted faxes' do
        do_delete
        expect(response).to redirect_to(aborted_faxes_path)
      end
    end

    context 'when fax missing' do
      before do
        allow(Fax).to receive(:find).and_return(nil)
      end

      it 'does not destroy fax' do
        do_delete
        expect(fax).not_to have_received(:destroy)
      end

      it 'redirect to aborted faxes' do
        do_delete
        expect(response).to redirect_to(aborted_faxes_path)
      end
    end
  end

  describe 'PATCH #deliver' do
    let(:fax) { double(:fax) }

    before do
      allow(Fax).to receive(:find).and_return(fax)
      allow(fax).to receive(:deliver)

      patch :deliver, id: '42'
    end

    it 'loads fax' do
      expect(Fax).to have_received(:find).with('42')
    end

    it 'assigns fax' do
      expect(assigns(:fax)).to eq fax
    end

    it 'delivers fax' do
      expect(fax).to have_received(:deliver)
    end

    it 'redirect to aborted faxes' do
      expect(response).to redirect_to(aborted_faxes_path)
    end
  end
end
