# As a user
# I want to easily deliver reports
# In order to save money

feature 'Deliver report' do
  let(:user) { create(:user) }
  let(:send_report) { 'Senden' }

  before do
    Rails.application.load_seed
    login_as user, scope: :user
  end

  scenario 'when pending' do
    report = create(:pending_report, user: user)
    visit report_url(report)
    expect(page).not_to have_link send_report
  end

  scenario 'when canceled' do
    report = create(:canceled_report, user: user)
    visit report_url(report)
    expect(page).not_to have_link send_report
  end

  scenario 'when verified' do
    report = create(:verified_report, user: user)
    visit report_url(report)
    expect(page).to have_link send_report
    click_link send_report
    click_button 'Druckauftrag erstellen'
    expect(page).to have_content('Druckauftrag wird gesendet')
  end

  scenario 'with active fax' do
    report = create(:verified_report, user: user)
    create(:active_print_job, report: report)
    visit report_url(report)
    expect(page).to have_link send_report
    expect(page).to have_content('Druckauftrag aktiv') # Label
  end

  scenario 'with completed fax' do
    report = create(:verified_report, user: user)
    create(:completed_print_job, report: report)
    visit report_url(report)
    expect(page).to have_link send_report
    expect(page).to have_content('Druckauftrag abgeschlossen') # Label
  end

  scenario 'with aborted fax' do
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

  scenario 'when undelivered' do
    report = create(:verified_report, user: user)
    visit reports_url
    click_link 'Ungesendet'
    expect(page).to have_content report.subject
  end

  scenario 'when delivered' do
    report = create(:verified_report, user: user)
    print_job = create(:completed_print_job, report: report)

    visit reports_url
    click_link 'Ungesendet'
    expect(page).not_to have_content report.subject
  end
end
