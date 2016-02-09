# As a doctor / user
# I want to verify reports
# In order to avoid that pending reports gets accidentially send.

feature 'Verify report' do
  before do
    # Disable fax delivery!
    allow_any_instance_of(Report).to receive(:deliver_as_fax)
  end

  scenario 'when pending' do
    user = create(:user)
    patient = create(:patient,
                     first_name:    'Chuck',
                     last_name:     'Norris',
                     date_of_birth: '1940-03-10')
    report = create(:report, user: user, patient: patient)
    expect(report).to be_pending

    login_as user, scope: :user

    visit report_url(report)
    expect(page).to have_content 'Norris, Chuck (* 10.03.1940)'

    expect(page).not_to have_content 'Vidiert'
    click_button 'Vidieren'

    expect(page).not_to have_button 'Vidieren'
    expect(page).to have_content 'Vidiert'

    report.reload
    expect(report).to be_verified
  end

  scenario 'when from other user' do
    user = create(:user)
    report = create(:report)

    login_as user, scope: :user

    visit report_url(report)
    expect(page).not_to have_button 'Vidieren'
  end
end
