class MoveStreetZipAndCityFromRecipientsToAddresses < ActiveRecord::Migration
  class Recipient < ActiveRecord::Base
  end

  class Address < ActiveRecord::Base
    validates_presence_of :street, :zip, :city
  end

  def up
    Recipient.reset_column_information
    Address.reset_column_information
    Recipient.where(address_id: nil).find_each do |recipient|
      address = Address.find_or_create_by(street: recipient.street,
                                          zip:    recipient.zip,
                                          city:   recipient.city)
      recipient.update_columns(address_id: address.id) if address.valid?
    end
    remove_column :recipients, :street
    remove_column :recipients, :city
    remove_column :recipients, :zip
  end

  def down
    Recipient.reset_column_information
    Address.reset_column_information
    add_column :recipients, :street, :string
    add_column :recipients, :city, :string
    add_column :recipients, :zip, :string
    Recipient.where.not(address_id: nil).find_each do |recipient|
      address = Address.find(recipient.address_id)
      recipient.update_columns(street:     address.street,
                               zip:        address.zip,
                               city:       address.city,
                               address_id: nil)
    end
  end
end
