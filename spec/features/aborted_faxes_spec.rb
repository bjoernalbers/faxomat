require 'spec_helper'

# I want to see the latest aborted faxes on one page
# so that I can retrigger them manually

feature 'Aborted faxes' do
  let(:deliverer) { double(:deliverer) }

  before do
    # NOTE: Disable delivery during tests!
    allow(Fax::Deliverer).to receive(:new).and_return(deliverer)
    allow(deliverer).to receive(:deliver)
  end

  scenario 'shows aborted faxes' do
    aborted_fax = create(:aborted_fax)
    completed_fax = create(:completed_fax)
    undelivered_fax = create(:fax)

    page = AbortedFaxesPage.new
    page.load

    expect(page).to have(1).faxes
    expect(page).to have_fax(aborted_fax)

    fax_section = page.faxes.first
    expect(fax_section.created_at.text).to eq(aborted_fax.created_at.to_s)
  end
end
