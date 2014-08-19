require 'spec_helper'

# In order check which faxes are (not) delivered
# As an MTA
# I want to see recent faxes and their state

feature 'Faxes List' do
  let(:app) { App.new }
  let(:page) { app.faxes_page }

  scenario 'shows fax title, recipient and state' do
    recipient = create(:recipient)
    fax = create(:fax, title: 'a nice fax',
                 recipient: recipient, state: 'completed')
    
    page.load

    expect(page).to have(1).faxes

    fax_section = page.faxes.first

    expect(fax_section.title.text).to eq(fax.title)
    expect(fax_section.phone.text).to eq(fax.phone)
    expect(fax_section.state.text).to eq('completed')
    expect(fax_section).to have_css('.completed')
  end
end
