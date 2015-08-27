class RenameRecipientIdToFaxNumberIdOnFaxes < ActiveRecord::Migration
  def change
    rename_column :faxes, :recipient_id, :fax_number_id
  end
end
