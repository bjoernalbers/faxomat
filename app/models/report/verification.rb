class Report::Verification
  include ActiveModel::Model

  attr_accessor :report, :user

  validates :report, :user, presence: true
  validate :models_are_valid, if: [ :report, :user ]

  def save
    ActiveRecord::Base.transaction { models.map(&:save!) }
    true
  rescue ActiveRecord::ActiveRecordError
    false
  end

  private

  def models_are_valid
    models.select(&:invalid?).each do |model|
      model.errors.each do |attribute, error|
        errors[attribute] << error unless errors[attribute].include? error
      end
    end
  end

  def models
    @models ||=
      (user.can_release_reports? ? [ signing, release ] : [ signing ])
  end

  def signing
    Report::Signing.new(report: report, user: user)
  end

  def release
    Report::Release.new(report: report, user: user)
  end
end
