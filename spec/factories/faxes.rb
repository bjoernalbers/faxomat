FactoryGirl.define do
  factory :fax do
    recipient
    title { 'hello' }
    document_file_name { Rails.root.join('spec', 'support', 'sample.pdf').to_s }
    document_file_size { 8421 }
    document_content_type { 'application/pdf' }
  end

  factory :completed_fax, parent: :fax do
    #state { 'completed' }
  end

  factory :aborted_fax, parent: :fax do
    after(:create) do |fax, evaluator|
      create(:aborted_print_job, fax: fax)
    end
  end
end
