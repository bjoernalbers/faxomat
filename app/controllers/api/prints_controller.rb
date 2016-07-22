module API
  class PrintsController < ApplicationController
    def index
      @prints = prints
    end

    private

    def prints
      Print.all
    end
  end
end
