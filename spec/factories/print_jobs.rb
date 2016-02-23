FactoryGirl.define do
  factory :print_job do
    fax_number
    title { 'hello' }
    cups_job_id { Faker::Number.number(6).to_i }
    status { :active }
    document_file_name { Rails.root.join('spec', 'support', 'sample.pdf').to_s }
    document_file_size { 8421 }
    document_content_type { 'application/pdf' }
  end

  factory :active_print_job, parent: :print_job do
    status { :active }
  end

  factory :completed_print_job, parent: :print_job do
    status { :completed }
  end

  factory :aborted_print_job, parent: :print_job do
    status { :aborted }
  end
end
