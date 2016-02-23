# As a user
# I want see unsent reports
# In order to process them in batches

feature 'Unsent reports' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'with unsent report' do
    report = create(:verified_report, user: user)
    visit reports_url
    click_link 'Ungesendet'
    expect(page).to have_content report.subject
  end

  scenario 'with sent report' do
    report = create(:verified_report, user: user)
    print_job = create(:completed_print_job, report: report)

    visit reports_url
    click_link 'Ungesendet'
    expect(page).not_to have_content report.subject
  end
end
