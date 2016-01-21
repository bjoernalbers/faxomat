class LettersController < ApplicationController
  before_action :authenticate_user!

  def create
    @letter = letters.new(letter_params)
    @letter.save!
    redirect_to @letter
  end

  def show
    letter = Letter.find(params[:id])
    send_file letter.document.path,
      type: letter.document.content_type,
      disposition: 'inline'
  end

  private

  def letters
    current_user.letters
  end

  def letter_params
    params.permit(:report_id)
  end
end
