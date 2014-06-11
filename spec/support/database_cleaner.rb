RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    #NOTE: Somehow transactions don't always delete faxes between runs! Fuck!
    #DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
