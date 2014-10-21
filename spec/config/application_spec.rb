require 'spec_helper'

describe Rails.application.config do
  describe '.dialout_prefix' do
    it 'is 0 by default' do
      expect(Rails.application.config.dialout_prefix).to eq 0
    end
  end
end
