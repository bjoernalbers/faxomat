class RemoveSexFromRecipients < ActiveRecord::Migration
  def change
    remove_column :recipients, :sex, :integer
  end
end
