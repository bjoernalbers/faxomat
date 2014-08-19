class AddTitleToFaxes < ActiveRecord::Migration
  class Fax < ActiveRecord::Base
    belongs_to :patient
  end

  class Patient < ActiveRecord::Base
    has_many :faxes

    def info
      format('%s, %s (* %s)',
             last_name,
             first_name,
             date_of_birth.strftime('%-d.%-m.%Y'))
    end
  end

  def up
    add_column :faxes, :title, :string
    Fax.reset_column_information
    Patient.reset_column_information
    Fax.all.each do |fax|
      fax.update!(title: fax.patient.info)
    end
  end

  def down
    remove_column :faxes, :title
  end
end
