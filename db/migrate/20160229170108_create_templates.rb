class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :title
      t.string :subtitle
      t.string :short_title
      t.string :slogan
      t.string :address
      t.string :zip
      t.string :city
      t.string :phone
      t.string :fax
      t.string :email
      t.string :homepage
      t.string :owners

      t.timestamps null: false
    end
  end
end
