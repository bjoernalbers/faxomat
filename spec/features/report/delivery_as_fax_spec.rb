# As a user
# I want send reports by fax
# In order to save money

feature 'Report delivery as fax' do
  before do
    # Disable fax delivery!
    allow_any_instance_of(Fax).to receive(:deliver)
  end

  let(:user) { create(:user) }
  let(:send_fax) { 'Fax senden' }

  before do
    login_as user, scope: :user
  end

  scenario 'with pending report' do
    report = create(:pending_report, user: user)
    visit report_url(report)
    expect(page).not_to have_button send_fax
  end

  scenario 'with canceled report' do
    report = create(:canceled_report, user: user)
    visit report_url(report)
    expect(page).not_to have_button send_fax
  end

  scenario 'with verified report' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    expect(page).to have_button send_fax
    click_button send_fax
    expect(page).to have_content('Fax wird gesendet')
  end

  scenario 'with active fax' do
    report = create(:verified_report, user: user)
    create(:active_fax, report: report)
    visit report_url(report)
    expect(page).not_to have_button send_fax
  end
end
