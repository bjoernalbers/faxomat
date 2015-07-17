class AddStateToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :state, :string
  end
end
