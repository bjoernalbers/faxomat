# As a doctor / user
# I want to approve reports
# In order to avoid that pending reports gets accidentially send.

include Warden::Test::Helpers
Warden.test_mode!

feature 'Approve Report' do
  before do
    # Disable fax delivery!
    allow_any_instance_of(Report).to receive(:deliver_as_fax)
  end

  scenario 'happy path' do
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

    expect(page).not_to have_content 'freigegeben'
    click_link 'freigeben'

    expect(page).not_to have_content 'freigegeben'
    report.reload
    expect(report).to be_approved

    expect(page).not_to have_link 'freigeben'
  end
end
