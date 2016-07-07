class ConvertNameOrderInTitleOnDocuments < ActiveRecord::Migration
  class Document < ActiveRecord::Base
  end

  def up
    regex = /^\s*(.+)\s*,\s+(.+)\s+(\(\*\s*\d+\.\d+\.\d+\s*\))$/
    Document.reset_column_information
    Document.find_each do |document|
      _, last_name, first_name, date_of_birth = regex.match(document.title).to_a
      fields = [ first_name, last_name, date_of_birth ]
      new_title = fields.any?(&:blank?) ? nil : fields.join(' ')
      if new_title
        document.update_columns(title: new_title)
      else
        puts "Could not convert title \"#{document.title}\" from document #{document.id}."
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
