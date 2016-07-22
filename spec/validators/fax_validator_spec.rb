describe FaxValidator do
  let(:subject) do
    class SampleModel
      include ActiveModel::Model
      attr_accessor :fax_number
      validates :fax_number,
        fax: true # This enables the FaxValidator.
    end
    SampleModel.new
  end

  describe '#fax_number' do
    include_examples 'should validate fax_number'

    it 'does not validate presence' do
      [nil, ''].each do |attr|
        subject.fax_number = attr
        expect(subject).to be_valid
      end
    end
  end
end
