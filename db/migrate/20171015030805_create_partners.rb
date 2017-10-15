class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.string :org_name
      t.string :phone_number

      t.timestamps null: false
    end
  end
end
