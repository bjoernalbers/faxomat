require 'spec_helper'

# In order to see which faxes are delivered
# As a user (MTA, doc, admin)
# I want to see if and when a fax was delivered

feature 'Fax' do
  scenario 'successfully delivered' do
    pending 'verification not implemented yet'
    fax = create(:fax)
    visit faxes_path
    expect(page).to have_no_css('.fax.delivered')

    # - deliver fax (run fax.deliver!)
    fax.should_receive(:status).and_return(:completed) # TODO: Un-fake this!

    visit faxes_path
    expect(page).to have_css('.fax.completed')
    # - verify that the fax contains a delivered_at timestamp
  end

  scenario 'delivery aborted' do
    #fax = create(:fax)
    #visit faxes_path
    #faxes_page = FaxesPage.new
    #fax = faxes_page.find(fax)
    
    # - verify that page does not list fax as deliverd
    #
    # exercise
    # - deliver fax (run fax.deliver!)
    # - verify delivery (how to mark fax as not deliverd during tests?)
    # - reload page
    #
    # verify
    # - verify that the fax is now marked as not delivered
  end
end

# NOTES: These tests only check the presentation. What about the actual delivery?
# - deliver un-delivered faxes # As class method?!
# - verify un-verified faxes # Also as class method?!
