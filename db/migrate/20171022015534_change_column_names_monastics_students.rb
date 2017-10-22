class ChangeColumnNamesMonasticsStudents < ActiveRecord::Migration
  def change
    rename_column :meetings, :student_id, :client_id
    rename_column :meetings, :monastic_id, :manager_id
  end
end
