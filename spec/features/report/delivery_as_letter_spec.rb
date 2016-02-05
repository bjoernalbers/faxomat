# As a user
# I want send reports by mail
# Because not every recipient owns a (working) fax-machine

feature 'Report delivery as letter' do
  let(:user) { create(:user) }
  let(:send_as_letter) { 'Brief senden' }

  before do
    login_as user, scope: :user
  end

  scenario 'with pending report' do
    report = create(:pending_report, user: user)
    visit report_url(report)
    expect(page).not_to have_button send_as_letter
  end

  scenario 'with verified report' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    expect(page).not_to have_content('Versendet')
    click_button send_as_letter
    expect(page).to have_content('Versendet')
  end

  scenario 'on undelivered reports page' do
    report = create(:verified_report, user: user)
    expect(report).not_to be_delivered
    visit reports_url
    click_link 'Unversendet'
    expect(page).to have_content(report.subject)
  end
end
