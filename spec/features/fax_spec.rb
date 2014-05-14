require 'spec_helper'

# In order check which faxes are (not) delivered
# As an MTA
# I want to see recent faxes and their state

feature 'Faxes List' do
  let(:app) { App.new }
  let(:page) { app.faxes_page }

  scenario 'shows fax title, recipient and state' do
    recipient = create(:recipient)
    fax = create(:fax, recipient: recipient)
    delivery = create(:delivery, fax: fax, print_job_state: 'awesome')
    
    page.load

    expect(page).to have(1).faxes
    expect(page.faxes.first.title.text).to eq(fax.title)
    expect(page.faxes.first.state.text).to eq('awesome')
    expect(page.faxes.first.phone.text).to eq(fax.phone)
    expect(page.faxes.first.created_at.text).to eq(fax.created_at.to_s)
  end
end
