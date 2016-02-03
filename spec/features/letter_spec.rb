# As a user
# I want send reports by mail
# Because not every recipient owns a (working) fax-machine

feature 'Send report as letter' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'with pending report' do
    report = create(:pending_report, user: user)
    visit report_url(report)
    expect(page).not_to have_button 'Brief senden'
  end

  scenario 'with verified report' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    expect(page).not_to have_content('Versendet')
    click_button 'Brief senden'
    visit page.driver.request.env['HTTP_REFERER'] # Goes back
    expect(page).to have_content('Versendet')
  end

  scenario 'on undelivered reports page' do
    report = create(:verified_report, user: user)
    expect(report).not_to be_delivered
    #visit '/reports?status=undelivered'
    visit reports_url
    click_link 'Unversendet'
    expect(page).to have_content(report.subject)
  end
end
