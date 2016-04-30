class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:show, :edit, :update]

  def show
  end

  def new
    @template = Template.new
  end

  def edit
  end

  def create
    @template = Template.new(template_params)
    if @template.save
      redirect_to @template, notice: 'Vorlage wurde erfolgreich erstellt.'
    else
      render :new
    end
  end

  def update
    if @template.update(template_params)
      redirect_to @template, notice: 'Vorlage wurde erfolgreich aktualisiert.'
    else
      render :edit
    end
  end

  private

  def set_template
    @template = Template.default
  end

  def template_params
    params.require(:template).permit(:title, :subtitle, :short_title, :slogan,
                                     :return_address, :contact_infos, :owners,
                                     :logo)
  end
end
