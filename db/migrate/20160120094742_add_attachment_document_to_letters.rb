class AddAttachmentDocumentToLetters < ActiveRecord::Migration
  def self.up
    change_table :letters do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :letters, :document
  end
end
