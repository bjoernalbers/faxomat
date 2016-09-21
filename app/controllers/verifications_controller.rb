class VerificationsController < ApplicationController
  before_action :load_report
  before_action :build_verification

  def create
    if @verification.save
      redirect_to reports_url, notice: 'Arztbrief erfolgreich vidiert'
    else
      redirect_to @report, alert: msg(@verification)
    end
  end

  private

  def load_report
    @report = Report.find(params[:report_id])
  end

  def build_verification
    @verification =
      Report::Verification.new(report: @report, user: current_user)
  end

  def msg(verification)
      details =
        verification.errors.empty? ? '...' : verification.errors.full_message.join(', ')
      "Oh Mist! Der Arztbrief konnte nicht vidiert werden: #{details}"
  end
end
