class RenameAddressToStreetOnRecipients < ActiveRecord::Migration
  def change
    rename_column :recipients, :address, :street
  end
end
