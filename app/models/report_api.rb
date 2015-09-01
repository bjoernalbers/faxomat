class ReportApi
  include ActiveModel::Model

  attr_accessor :subject, :content, :username

  validates_presence_of :subject, :content, :username
  validate :validate_existence_of_username

  #TODO: Check if this is required!
  def self.model_name
    ActiveModel::Name.new(self, nil, "Report")
  end

  def save
    if valid?
      #@report ||= Report.new(subject: subject, content: content, user: user)
      report = Report.new(subject: subject, content: content, user_id: user.id)
      report.save!
      true
    else
      false
    end
  end

  private

  def validate_existence_of_username
    unless user
      errors.add :username, 'does not exist'
    end
  end

  def user
    @user ||= User.find_by(username: username)
  end
end
