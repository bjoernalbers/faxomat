require 'spec_helper'

# I want to see the latest deliverable faxes on one page
# so that I can retrigger them manually

feature 'Undeliverable faxes' do
  let(:deliverer) { double(:deliverer) }

  before do
    # NOTE: Disable delivery during tests!
    allow(Fax::Deliverer).to receive(:new).and_return(deliverer)
    allow(deliverer).to receive(:deliver)
  end

  scenario 'shows only undeliverable faxes' do
    aborted_fax = create(:aborted_fax)
    undeliverable_fax = create(:fax, state: 'undeliverable')
    completed_fax = create(:completed_fax)
    undelivered_fax = create(:fax)

    page = UndeliverableFaxesPage.new
    page.load

    expect(page.faxes.size).to eq 1
    expect(page).to have_fax(undeliverable_fax)

    fax_section = page.faxes.first
    expect(fax_section.created_at.text).to eq(undeliverable_fax.created_at.to_s)
  end
end
