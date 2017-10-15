class AddFieldstoMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :duration, :float
    add_column :meetings, :provider_id, :integer
  end
end
