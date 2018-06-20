class AddSendWithHylaFaxToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :send_with_hylafax, :boolean, null: false, default: false
  end
end
