class AddMissingIndexes < ActiveRecord::Migration
  def change
    # add_index :meetings, :meeting_type_id
    # add_index :meetings, :monastic_id
    # add_index :meetings, :student_id
    # add_index :notes, :note_type_id
    # add_index :students, :category_type_id
    # add_index :students_groups, :group_id
    # add_index :students_groups, :student_id
    # add_index :students_sittings, :attendance_status_type_id
    # add_index :students_sittings, :location_type_id
    add_index :students_sittings, :meeting_id
    add_index :students_sittings, :sitting_id
    add_index :students_sittings, :special_status_type_id
    add_index :students_sittings, :student_id
  end
end
