module API
  class FaxesController < ApplicationController
    def index
      @faxes = faxes
    end

    private

    def faxes
      Fax.all
    end
  end
end
