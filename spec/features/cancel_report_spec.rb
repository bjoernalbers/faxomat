# As a doctor / user
# I want to cancel reports
# In order to avoid that invalid reports gets accidentially send.

feature 'Cancel report' do
  scenario 'when verified' do
    user = create(:user)
    patient = create(:patient,
                     first_name:    'Chuck',
                     last_name:     'Norris',
                     date_of_birth: '1940-03-10')
    report = create(:verified_report, user: user, patient: patient)

    login_as user, scope: :user

    visit report_url(report)

    expect(page).not_to have_content 'Storniert'

    click_button 'Stornieren'

    expect(page).not_to have_button 'Stornieren'
    expect(page).to have_content 'Storniert'

    report.reload
    expect(report).to be_canceled
  end

  #scenario 'when from other user' do
    #user = create(:user)
    #report = create(:report)
#
    #login_as user, scope: :user
#
    #visit report_url(report)
    #expect(page).not_to have_button 'Vidieren'
  #end
end
