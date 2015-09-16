class AddFaxNumberIdToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :fax_number_id, :integer
  end
end
