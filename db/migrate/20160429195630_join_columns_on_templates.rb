class JoinColumnsOnTemplates < ActiveRecord::Migration
  def up
    %i(return_address contact_infos).each do |column|
      add_column :templates, column, :string
    end
    %i(address city zip phone fax email homepage).each do |column|
      remove_column :templates, column, :string
    end
  end

  def down
    %i(return_address contact_infos).each do |column|
      remove_column :templates, column, :string
    end
    %i(address city zip phone fax email homepage).each do |column|
      add_column :templates, column, :string
    end
  end
end
