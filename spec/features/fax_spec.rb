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
    expect(page.faxes.first.phone.text).to eq(fax.phone)
  end

  scenario 'shows time and state of last delivery' do
    recipient = create(:recipient)
    fax = create(:fax, recipient: recipient)
    old_delivery = create(:delivery, fax: fax, print_job_state: 'aborted')
    new_delivery = create(:delivery, fax: fax, print_job_state: 'completed',
                          created_at: old_delivery.created_at + 1.second)

    page.load

    fax_section = page.faxes.first

    expect(fax_section.state.text).to eq(new_delivery.print_job_state)
    expect(fax_section.last_delivery_at.text).to eq(new_delivery.created_at.to_s)
    expect(fax_section).to have_css(".#{new_delivery.print_job_state}")
  end
end
