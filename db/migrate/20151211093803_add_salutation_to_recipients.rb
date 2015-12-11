class AddSalutationToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :salutation, :string
  end
end
