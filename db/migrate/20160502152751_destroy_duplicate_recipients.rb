class DestroyDuplicateRecipients < ActiveRecord::Migration
  class Recipient < ActiveRecord::Base
  end

  class Report < ActiveRecord::Base
  end

  def up
    Recipient.reset_column_information
    Report.reset_column_information
    params = %w(title first_name last_name suffix address city zip)
    Recipient.select(params).group(params).having('count(1) > 1').
      all.each do |group|
        duplicates = Recipient.where(group.attributes.slice(*params)).
          order(:created_at)
        duplicates_with_fax_number = duplicates.where.not(fax_number: nil)
        if duplicates_with_fax_number.present?
          recipient = duplicates_with_fax_number.last
        else
          recipient = duplicates.last
        end
        duplicates_ids = duplicates.where.not(id: recipient.id).pluck(:id)
        if recipient.present? && duplicates_ids.present?
          Report.where(recipient_id: duplicates_ids).
            update_all(recipient_id: recipient.id)
          Recipient.where(id: duplicates_ids).destroy_all
        end
    end
  end

  def down
    # Nothing to do here.
  end
end
