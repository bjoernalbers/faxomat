class SigningsController < ApplicationController
  before_action :load_signing, only: [:destroy]
  def destroy
    if @signing.destroy
      redirect_to @signing.report,
        notice: 'Vidierung erfolgreich gelöscht'
    else
      redirect_to @signing.report,
        alert: "Vidierung nicht löschbar: #{@signing.errors.full_messages.join(', ')}"
    end
  end

  private

  def load_signing
    @signing = Report::Signing.find(params[:id])
  end
end
