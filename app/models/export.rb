class Export < ActiveRecord::Base
  include Deliverable

  belongs_to :directory,
    required: true

  before_create :set_filename, unless: :filename
  before_create :copy_file

  def source
    @source ||= Pathname.new(document.path)
  end

  def destination
    @destination ||= directory.path + filename
  end

  private

  def set_filename
    self.filename = Filename.new(document).to_s
  end

  def copy_file
    copy_file!
    true
  rescue SystemCallError => e
    errors[:base] << e
    false
  end

  def copy_file!
    with_retry { FileUtils.cp(source, destination) }
  end

  def with_retry(retries = 3)
    yield
  rescue StandardError => e
    if (retries -= 1) > 0
      sleep 1
      retry
    end
    raise e
  end
end
