class AddAttachmentDocumentToFaxes < ActiveRecord::Migration
  def self.up
    change_table :faxes do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :faxes, :document
  end
end
