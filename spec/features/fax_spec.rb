require 'spec_helper'

# In order check which faxes are (not) delivered
# As an MTA
# I want to see recent faxes and their status

feature 'Faxes List' do
  let(:app) { App.new }
  let(:page) { app.faxes_page }

  scenario 'shows fax title, recipient and status' do
    recipient = create(:recipient)
    fax = create(:fax, title: 'a nice fax',
                 recipient: recipient)
    
    page.load

    expect(page.faxes.count).to eq 1

    fax_section = page.faxes.first

    expect(fax_section.title.text).to eq(fax.title)
    expect(fax_section.phone.text).to eq(fax.phone)
    expect(fax_section.status.text).to eq('pending')
    expect(fax_section).to have_css('.pending')
  end
end
