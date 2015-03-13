require 'spec_helper'

# In order know what is currently being delivered (or not)
# As a user
# I want to view faxes

feature 'View faxes' do
  let(:app) { App.new }

  scenario 'when aborted' do
    page = app.aborted_faxes_page
    fax = create(:aborted_fax)

    page.load

    expect(page.faxes.count).to eq 1
    fax_section = page.faxes.first
    expect(fax_section.title.text).to eq(fax.title)
    expect(fax_section.phone.text).to eq(fax.phone)
    expect(fax_section.status.text).to eq('aborted')
    expect(fax_section).to have_css('.aborted')
  end

  scenario 'when active' do
    page = app.faxes_page
    fax = create(:active_fax)

    page.load

    expect(page.faxes.count).to eq 1
    fax_section = page.faxes.first
    expect(fax_section.title.text).to eq(fax.title)
    expect(fax_section.phone.text).to eq(fax.phone)
    expect(fax_section.status.text).to eq('active')
    expect(fax_section).to have_css('.active')
  end
end
