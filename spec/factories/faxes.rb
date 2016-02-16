FactoryGirl.define do
  factory :fax do
    fax_number
    title { 'hello' }
    cups_job_id { Faker::Number.number(6).to_i }
    status { :active }
    document_file_name { Rails.root.join('spec', 'support', 'sample.pdf').to_s }
    document_file_size { 8421 }
    document_content_type { 'application/pdf' }
  end

  factory :active_fax, parent: :fax do
    status { :active }
  end

  factory :completed_fax, parent: :fax do
    status { :completed }
  end

  factory :aborted_fax, parent: :fax do
    status { :aborted }
  end
end
