class AddFieldstoMeetings2 < ActiveRecord::Migration
  def change
    rename_column :meetings, :provider_id, :partner_id
  end
end
