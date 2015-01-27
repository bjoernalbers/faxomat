FactoryGirl.define do
  factory :fax do
    recipient
    title { 'hello' }
    sequence :print_job_id # NOTE: This will bypass the delivery mechanism!
    document_file_name { Rails.root.join('spec', 'support', 'sample.pdf').to_s }
    document_file_size { 8421 }
    document_content_type { 'application/pdf' }
  end

  factory :completed_fax, parent: :fax do
    state { 'completed' }
  end

  factory :aborted_fax, parent: :fax do
    state { 'aborted' }
  end
end
