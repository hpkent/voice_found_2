class ChangeStudenttoClient < ActiveRecord::Migration
  def change
    rename_table :students, :clients
  end
end
