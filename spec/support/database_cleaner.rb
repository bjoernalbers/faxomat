RSpec.configure do |config|

  config.before(:suite) do
    #DatabaseCleaner.strategy = :transaction
    #DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end
