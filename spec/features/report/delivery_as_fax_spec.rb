# As a user
# I want send reports by fax
# In order to save money

feature 'Report delivery as fax' do
  let(:user) { create(:user) }
  let(:send_fax) { 'Fax senden' }

  before do
    Rails.application.load_seed
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
    expect(page).to have_content('Druckauftrag wird gesendet')
  end

  scenario 'with active fax' do
    report = create(:verified_report, user: user)
    create(:active_print_job, report: report)
    visit report_url(report)
    expect(page).not_to have_button send_fax
    expect(page).to have_content('Druckauftrag aktiv') # Label
  end

  scenario 'with completed fax' do
    report = create(:verified_report, user: user)
    create(:completed_print_job, report: report)
    visit report_url(report)
    expect(page).to have_button send_fax
    expect(page).to have_content('Druckauftrag abgeschlossen') # Label
  end

  scenario 'with aborted fax' do
    report = create(:verified_report, user: user)
    create(:aborted_print_job, report: report)
    visit report_url(report)
    expect(page).to have_button send_fax
    expect(page).to have_content('Druckauftrag abgebrochen') # Label
  end
end
