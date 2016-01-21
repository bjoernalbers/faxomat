# As a user
# I want send reports by mail
# Because not every recipient owns a (working) fax-machine

feature 'Mail' do
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

    expect(page).not_to have_content('versendet am')
    click_button 'Brief senden'

    # Whats comming next?

    visit report_url(report)
    expect(page).to have_content('versendet am')
  end
end
