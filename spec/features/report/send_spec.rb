# As a user
# I want send reports
# In order to save money

feature 'Send report' do
  let(:user) { create(:user) }
  let(:send_report) { 'Senden' }

  before do
    Rails.application.load_seed
    login_as user, scope: :user
  end

  scenario 'when pending is not possible' do
    report = create(:pending_report, user: user)
    visit report_url(report)
    expect(page).not_to have_link send_report
  end

  scenario 'when canceled is not possible' do
    report = create(:canceled_report, user: user)
    visit report_url(report)
    expect(page).not_to have_link send_report
  end

  scenario 'when verified is possible' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    expect(page).to have_link send_report
    click_link send_report
    click_button 'Druckauftrag erstellen'
    expect(page).to have_content('Druckauftrag wird gesendet')
  end

  scenario 'with active fax is not possible' do
    report = create(:verified_report, user: user)
    create(:active_print_job, report: report)
    visit report_url(report)
    expect(page).not_to have_link send_report
    expect(page).to have_content('Druckauftrag aktiv') # Label
  end

  scenario 'with completed fax is possible' do
    report = create(:verified_report, user: user)
    create(:completed_print_job, report: report)
    visit report_url(report)
    expect(page).to have_link send_report
    expect(page).to have_content('Druckauftrag abgeschlossen') # Label
  end

  scenario 'with aborted fax is possible' do
    report = create(:verified_report, user: user)
    create(:aborted_print_job, report: report)
    visit report_url(report)
    expect(page).to have_link send_report
    expect(page).to have_content('Druckauftrag abgebrochen') # Label
  end

  scenario 'when canceled' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    click_link send_report
    click_link 'Abbrechen'
    expect(current_path).to eq report_path(report)
  end
end
