class Export < ActiveRecord::Base
  include Deliverable

  belongs_to :directory,
    required: true

  before_create :set_filename, unless: :filename
  before_create :export

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

  def export
    if copy_file
      self.status = :completed
      true
    else
      false
    end
  end

  def copy_file
    copy_file!
    true
  rescue SystemCallError => e
    errors[:base] << e
    false
  end

  def copy_file!
    FileUtils.cp(source, destination)
  end
end
