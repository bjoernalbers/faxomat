# As a doctor / user
# I want to verify reports
# In order to avoid that pending reports gets accidentially send.

feature 'Verify report' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user

    Rails.application.load_seed # To make the fax printer available!
  end

  scenario 'when pending' do
    patient = create(:patient,
                     first_name:    'Chuck',
                     last_name:     'Norris',
                     date_of_birth: '1940-03-10')
    report = create(:pending_report, user: user, patient: patient)

    visit report_url(report)
    expect(page).to have_content patient

    expect(page).not_to have_content 'Vidiert'
    click_button 'Vidieren'

    visit report_url(report)

    expect(page).not_to have_button 'Vidieren'
    expect(page).to have_content 'Vidiert'

    report.reload
    expect(report).to be_verified
  end

  scenario 'when from other user' do
    pending
    report = create(:report)

    visit report_url(report)
    expect(page).not_to have_button 'Vidieren'
  end

  scenario 'when not logged in' do
    patient = create(:patient,
                     first_name:    'Chuck',
                     last_name:     'Norris',
                     date_of_birth: '1940-03-10')
    report = create(:report, user: user, patient: patient)
    logout(:user)
    visit report_url(report)
    expect(page).to have_content patient
    expect(page).not_to have_button 'Vidieren'
  end
end
