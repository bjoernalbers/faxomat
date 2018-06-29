class ChangeSendWithHylafaxOnRecipients < ActiveRecord::Migration
  class Recipient < ActiveRecord::Base
  end

  def up
    change_column :recipients, :send_with_hylafax, :boolean, null: false, default: true
    Recipient.reset_column_information
    Recipient.update_all(send_with_hylafax: true)
  end

  def down
    change_column :recipients, :send_with_hylafax, :boolean, null: false, default: false
    Recipient.reset_column_information
    Recipient.update_all(send_with_hylafax: false)
  end
end
