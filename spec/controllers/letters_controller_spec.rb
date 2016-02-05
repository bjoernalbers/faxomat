describe LettersController do
  def current_user
    subject.current_user
  end

  # NOTE: Taken from...
  # https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-%28and-RSpec%29
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:report) { create(:verified_report) }

      def do_post
        post :create, report_id: report
      end

      it 'creates letter for current user' do
        expect {
          do_post
        }.to change(current_user.letters, :count).by(1)
      end

      it 'displays letter as PDF' do
        do_post
        expect(response).to redirect_to report_path(report)
      end
    end

    context 'with invalid params' do
      it 'includes error message'
      it 'redirects to report url'
    end
  end

  describe 'GET #show' do
    it 'displays letter as PDF' do
      # NOTE: This fixes the missing template error
      # (see http://stackoverflow.com/questions/4701108/rspec-send-file-testing)
      allow(controller).to receive(:render)

      letter = create(:letter)
      expect(controller).to receive(:send_file).
        with(letter.document.path, type: 'application/pdf')
      get :show, id: letter
    end
  end
end
