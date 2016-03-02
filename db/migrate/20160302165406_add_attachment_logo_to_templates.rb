class AddAttachmentLogoToTemplates < ActiveRecord::Migration
  def up
    add_attachment :templates, :logo
  end

  def down
    remove_attachment :templates, :logo
  end
end
