require 'spec_helper'

feature 'View documents' do
  scenario 'single job imported' do
    # setup
    job = Job.new(phone: '0123456789',
                  path: '/tmp/letter.pdf',
                  patient_first_name: 'Chuck',
                  patient_last_name: 'Norris',
                  patient_date_of_birth: '1940-03-10')
    job.save
    job = Job.new(phone: '0123455555',
                  path: '/tmp/letter.pdf',
                  patient_first_name: 'Arnold',
                  patient_last_name: 'Schwarzenegger',
                  patient_date_of_birth: '1947-07-30')
    job.save

    recipient = Recipient.find_by phone: '0123456789'
    #visit recipient_path(recipient)
    visit faxes_path(recipient_id: recipient)

    expect(page).to have_content('Norris, Chuck (* 10.3.1940)')
    expect(page).to_not have_content('Schwarzenegger, Arnold (* 30.7.1947)')
  end
end
