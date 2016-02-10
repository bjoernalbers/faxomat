describe ReportFaxesController do
  # NOTE: Taken from...
  # https://github.com/plataformatec/devise/wiki/How-To:-Test-controllers-with-Rails-3-and-4-%28and-RSpec%29
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:user)
    sign_in user
    user
  end

  before do
    # Disable fax delivery!
    allow_any_instance_of(Fax).to receive(:deliver)
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:report) { create(:verified_report) }

      def do_post
        post :create, report_id: report
      end

      it 'creates fax for report' do
        expect(report.faxes).to be_empty
        do_post
        report.reload
        expect(report.faxes).not_to be_empty
      end

      it 'redirects to report' do
        do_post
        expect(response).to redirect_to report_path(report)
      end

      it 'sets flash notice'
    end

    context 'with invalid params' do
      it 'includes error message'
      it 'redirects to report url'
    end
  end
end