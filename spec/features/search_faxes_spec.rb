require 'spec_helper'

# I want to find faxes by patient data
# because we have many many many faxes.

feature 'Search faxes' do
  scenario 'by date of birth' do
    patient = create(:patient,
                     first_name: 'Bruce',
                     last_name: 'Willis',
                     date_of_birth: '1955-03-19')
    fax = create(:fax, patient: patient)

    page = SearchFaxesPage.new
    page.load(q: '19.3.1955')

    expect(page).to have(1).faxes
    expect(page).to have_fax(fax)

    #fax_section = page.faxes.first
    #expect(fax_section.created_at.text).to eq(aborted_fax.created_at.to_s)
  end
end
