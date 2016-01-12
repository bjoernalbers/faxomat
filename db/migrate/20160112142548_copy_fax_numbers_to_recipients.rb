class CopyFaxNumbersToRecipients < ActiveRecord::Migration
  def up
    add_column :recipients, :fax_number, :string

    Recipient.find_each do |recipient|
      if recipient.fax_number.present?
        fax_number = FaxNumber.find(recipient.fax_number_id).phone
        recipient.update_columns fax_number: fax_number
      end
    end

    remove_column :recipients, :fax_number_id, :integer
  end

  def down
    add_column :recipients, :fax_number_id, :integer

    Recipient.find_each do |recipient|
      if fax_number = recipient.read_attribute(:fax_number)
        fax_number = FaxNumber.find_or_create_by!(phone: fax_number)
        recipient.update_columns fax_number_id: fax_number.id
      end
    end

    remove_column :recipients, :fax_number, :string
  end
end
