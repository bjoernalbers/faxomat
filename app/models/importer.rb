# Import jobs from JSON files into the database.
class Importer
  attr_reader :file

  # @param [String] Path to JSON file
  def initialize(file)
    @file = file
  end

  # Import the job and delete the file on success.
  def run
    FileUtils.rm(file) if job.save
  end

  # @returns [Job] New job
  def job
    Job.new(clean_attributes)
  end

  private

  # @returns [Hash]
  def clean_attributes
    attr = attributes
    attr['path'] = attr['file'] if attr['file']
    attr.slice(
      'patient_first_name',
      'patient_last_name',
      'patient_date_of_birth',
      'phone',
      'path')
  end

  # @returns [Hash]
  def attributes
    JSON.parse(json)
  end

  # @returns [String] UTF-8 encoded JSON from file
  def json
    File.read(file).encode('UTF-8', 'MacRoman')
  end
end
