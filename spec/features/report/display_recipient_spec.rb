# As a doctor / user
# I want to see the report's recipient
# In order to check it before verification

feature 'Display report recipient' do
  let(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  scenario 'happy path' do
    recipient = create(:recipient)
    report = create(:pending_report, user: user, recipient: recipient)
    document = create(:document, report: report, recipient: recipient)

    visit report_url(report)

    expect(page).to have_content recipient.last_name
    expect(page).to have_content recipient.first_name
    expect(page).to have_content recipient.title
    expect(page).to have_content recipient.suffix
    expect(page).to have_content recipient.street
    expect(page).to have_content recipient.zip
    expect(page).to have_content recipient.city
    expect(page).to have_content recipient.fax_number
  end

  scenario 'without fax number' do
    recipient = create(:recipient, fax_number: nil)
    report = create(:pending_report, user: user, recipient: recipient)
    document = create(:document, report: report, recipient: recipient)

    visit report_url(report)

    expect(page).to have_content 'Faxnummer fehlt!'
  end
end
