class AddRecipientToDocuments < ActiveRecord::Migration
  def change
    add_reference :documents, :recipient, index: true, foreign_key: true
  end
end
