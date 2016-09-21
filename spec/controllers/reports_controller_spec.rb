describe ReportsController do
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

    Rails.application.load_seed # To make the fax printer available!
  end

  describe 'GET #show' do
    let!(:report) { create(:report, user: current_user) }

    def do_get
      get :show, id: report
    end

    it 'does not require authentication' do
      sign_out current_user
      do_get
      expect(response).to be_success
    end
  end

  describe 'DELETE #destroy' do
    def do_delete
      delete :destroy, id: report
    end

    context 'with pending report' do
      let!(:report) { create(:pending_report, user: current_user) }

      it 'destroys report' do
        expect {
          do_delete
        }.to change(Report, :count).by(-1)
      end

      it 'redirects to reports URL' do
        do_delete
        expect(response).to redirect_to reports_url
      end

      it 'sets flash notice' do
        do_delete
        expect(flash[:notice]).to eq 'Der Arztbrief wurde gelöscht.'
      end
    end

    context 'with verified report' do
      let!(:report) { create(:verified_report, user: current_user) }

      it 'does not destroy report' do
        expect {
          do_delete
        }.to change(Report, :count).by(0)
      end

      it 'renders report URL' do
        do_delete
        expect(response).to redirect_to report_url(report)
      end

      it 'sets flash error' do
        do_delete
        expect(flash[:alert]).not_to be nil
      end
    end

    context 'with report from other user' do
      let!(:report) { create(:pending_report) }

      it 'raises error' do
        expect {
          do_delete
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe 'PATCH #update' do
    let(:report) { create(:pending_report, user: current_user) }

    def do_patch
      patch :update, id: report, 'diagnosis' => 'chunky bacon'
    end

    context 'with valid params' do
      it 'updates report' do
        do_patch
        report.reload
        expect(report.diagnosis).to eq 'chunky bacon'
      end

      it 'redirects to report' do
        do_patch
        expect(response).to redirect_to report_url(report)
      end
    end

    context 'with invalid params' do
      def do_patch
        patch :update, id: report, 'study' => ''
      end

      it 'does not update report' do
        do_patch
        report.reload
        expect(report).to be_pending
      end

      it 'renders show template' do
        pending
        do_patch
        expect(response).to render_template :show
      end
    end

    context 'with report from other user' do
      let!(:report) { create(:pending_report) }

      it 'raises error' do
        expect {
          do_patch
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
