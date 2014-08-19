require 'spec_helper'

# In order to find older faxes
# As a user with maaaaaaaaannny faxes
# I want to be able to search them

feature 'Search faxes' do
  scenario 'by title' do
    fax = create(:fax, title: 'My SWEET litle fax')
    other_fax = create(:fax, title: 'another boring one')

    page = SearchFaxesPage.new
    page.load(q: 'sweet')
    #page.load(q: '')

    expect(page).to have_fax(fax)
    expect(page).to_not have_fax(other_fax)
    expect(page).to have(1).faxes

    #fax_section = page.faxes.first
    #expect(fax_section.created_at.text).to eq(aborted_fax.created_at.to_s)
  end
end
