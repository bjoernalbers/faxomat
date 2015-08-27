class RenameRecipientsToFaxNumbers < ActiveRecord::Migration
  def change
    rename_table :recipients, :fax_numbers
  end
end
