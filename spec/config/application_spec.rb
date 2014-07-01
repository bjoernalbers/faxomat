require 'spec_helper'

describe Rails.application.config do
  describe '.dialout_prefix' do
    it 'is nil by default' do
      expect(Rails.application.config.dialout_prefix).to be_nil
    end
  end
end
