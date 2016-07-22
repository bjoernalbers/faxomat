class RenamePrintJobsToPrintsOnDeliveries < ActiveRecord::Migration
  class Delivery < ActiveRecord::Base
  end

  def up
    Delivery.reset_column_information
    Delivery.where(type: 'PrintJob').update_all(type: 'Print')
  end

  def down
    Delivery.reset_column_information
    Delivery.where(type: 'Print').update_all(type: 'PrintJob')
  end
end
