# As a user
# I want to easily deliver reports
# In order to save money

feature 'Deliver report' do
  let(:user) { create(:user) }
  let(:send_report) { 'Senden' }
  let(:deliver_report) { 'Faxen' }

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
    click_button deliver_report
  end

  scenario 'with active fax' do
    report = create(:verified_report, user: user)
    create(:active_print_job, document: report.document)
    visit report_url(report)
    expect(page).to have_link send_report
  end

  scenario 'with completed fax' do
    report = create(:verified_report, user: user)
    create(:completed_print_job, document: report.document)
    visit report_url(report)
    expect(page).to have_link send_report
  end

  scenario 'with aborted fax' do
    report = create(:verified_report, user: user)
    create(:aborted_print_job, document: report.document)
    visit report_url(report)
    expect(page).to have_link send_report
  end
end
