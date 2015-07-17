class CopyPrintJobIdAndStateFromDeliveriesToFaxes < ActiveRecord::Migration
  class Fax < ActiveRecord::Base
    has_many :deliveries
  end

  class Delivery < ActiveRecord::Base
    belongs_to :fax
  end
    
  def up
    Fax.reset_column_information
    Delivery.reset_column_information
    Fax.all.each do |fax|
      last_delivery = fax.deliveries.order(:created_at).last
      if last_delivery && fax.print_job_id.nil?
        fax.update(print_job_id: last_delivery.print_job_id,
                   state: last_delivery.print_job_state)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
