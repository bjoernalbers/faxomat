class ChangeRecipientIdOnFaxes < ActiveRecord::Migration
  def change
    change_column :faxes, :recipient_id, :integer, null: false
  end
end
