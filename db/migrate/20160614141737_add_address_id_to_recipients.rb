class AddAddressIdToRecipients < ActiveRecord::Migration
  def change
    add_reference :recipients, :address, index: true, foreign_key: true
  end
end
