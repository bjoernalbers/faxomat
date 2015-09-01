module API
  class Report
    include ActiveModel::Model

    attr_accessor :subject, :content, :username

    attr_reader :report

    validates_presence_of :subject, :content, :username
    validate :validate_existence_of_username

    def save
      if valid?
        @report ||= ::Report.new(subject: subject, content: content,
                                 user_id: user.id)
        report.save!
        true
      else
        false
      end
    end

    def id
      report.id
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
end
