# As a doctor / user
# I want to download reports
# In order to see the actual PDF document.

feature 'Download report' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user

    Rails.application.load_seed # To make the fax printer available!
  end

  scenario 'when pending' do
    report = create(:verified_report, user: user)
    document = create(:document, report: report)

    visit report_url(report)
    click_link 'Öffnen'

    expect(page.response_headers['Content-Type']).to eq 'application/pdf'
  end
end
