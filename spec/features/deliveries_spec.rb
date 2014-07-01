require 'spec_helper'

feature 'deliveries' do
  scenario 'one undelivered fax' do
    fax = create(:fax, print_job_id: nil, state: nil)

    print_job = double('print_job', print: true, job_id: 42, :title= => nil)
    allow(Cups::PrintJob).to receive(:new).and_return(print_job)

    Fax.deliver

    expect(Cups::PrintJob).to have_received(:new).
      with(fax.path, 'Fax', {'phone' => fax.phone})
    expect(print_job).to have_received(:print)

    fax.reload
    expect(fax.print_job_id).to eq(print_job.job_id)
  end
end
