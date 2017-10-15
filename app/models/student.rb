class Student < ActiveRecord::Base
  has_many :students_sittings
  has_many :sittings, through: :students_sittings
  has_many :meetings
  has_many :students_groups
  belongs_to :category_type
  scope :search_by_name, lambda { |q|
   (q ? where(["first_name LIKE ? or last_name LIKE ? or concat(first_name, ' ', last_name) like ?", '%'+ q + '%', '%'+ q + '%','%'+ q + '%' ])  : {})
  }

  def calc_last_seen(sitting_id,s)
    @sitting = Sitting.find(sitting_id)
    now = @sitting.start_date
    @default_date = now
    # @attending_students.each do |s|
      # m = s.meetings.where('meetings.start_date!=?',Date.today)
    m = s.meetings.where('meetings.start_time!=?',@sitting.start_time)
    if m.length == 0 then
      # Student.find(s.id).update(:date_last_seen => @default_date)
      # Student.find(s.id).update(:days_since_last_seen => (now - @default_date).to_i)
      # puts "test test: #{s.meetings.length}"
    elsif m.length > 0
       s.date_last_seen = m.order('start_date DESC').first.start_date
       Student.find(s.id).update(:date_last_seen => s.date_last_seen)
       Student.find(s.id).update(:days_since_last_seen => (now - s.date_last_seen).to_i)
       puts "test test: #{s.meetings.length}"
    end
  end

  def calc_last_attended(student)
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    student_sitting = StudentsSitting.joins('
    LEFT OUTER JOIN sittings ON sittings.id = students_sittings.sitting_id
    LEFT OUTER JOIN attendance_status_types ON attendance_status_types.id = students_sittings.attendance_status_type_id'
    ).where("
    students_sittings.student_id =? AND students_sittings.attendance_status_type_id=?", student, @attendance_status_type_id_present).order('sittings.start_date DESC').first
    if student_sitting != nil
      last_sitting_id = student_sitting.sitting_id
      last_sitting_date = Sitting.find(last_sitting_id).start_date
      puts "student: #{student.first_name} last_sitting: #{last_sitting_date}"
      last_sitting_date
    end
  end

  def calc_wrong_category(student)
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    student_sitting = StudentsSitting.joins('
    LEFT OUTER JOIN sittings ON sittings.id = students_sittings.sitting_id
    LEFT OUTER JOIN attendance_status_types ON attendance_status_types.id = students_sittings.attendance_status_type_id'
    ).where("
    students_sittings.student_id =? AND students_sittings.attendance_status_type_id=?", student, @attendance_status_type_id_present).order('sittings.start_date DESC').first
    #nil result returned if student likely in wrong category
    student_sitting
  end

  def self.active_student

    @inactive_student = Student.all
  end

  def self.inactive_student

    @inactive_student = Student.all
  end

  def self.absent_student
    @absent_student = Student.all
  end
end
