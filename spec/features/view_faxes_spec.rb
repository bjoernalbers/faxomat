require 'spec_helper'

# In order know what is currently being delivered (or not)
# As a user
# I want to view faxes

feature 'View faxes' do
  let(:app) { App.new }
  let(:page) { app.aborted_faxes_page }

  scenario 'when aborted' do
    fax = create(:aborted_fax)

    page.load

    expect(page.faxes.count).to eq 1
    fax_section = page.faxes.first
    expect(fax_section.title.text).to eq(fax.title)
    expect(fax_section.phone.text).to eq(fax.phone)
    expect(fax_section.status.text).to eq('aborted')
    expect(fax_section).to have_css('.aborted')
  end
end
