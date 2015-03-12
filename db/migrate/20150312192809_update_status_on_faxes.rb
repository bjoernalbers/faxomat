class UpdateStatusOnFaxes < ActiveRecord::Migration
  def change
    Fax.find_each do |fax|
      fax.save
    end
  end
end
