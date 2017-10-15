class ReportsController < ApplicationController

  def new
  end

  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, params["#{field_name.to_s}(2i)"].to_i, params["#{field_name.to_s}(3i)"].to_i)
  end

  def student_report
    report_start_date = build_date_from_params("start_date", params[:report])
    report_end_date = build_date_from_params("end_date", params[:report])
    @student = params[:Name]
    @student = @student.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '')
    puts @student
    if @student.match(" ")
      #student has two names
      student_array = @student.split(" ")
      @first_name = student_array[0]
      @last_name = student_array[1]
      puts "full name: #{@first_name}"
      @student_sittings_report = Meeting.select('students.first_name AS student_first_name, monastics.initials AS monastic_initials').joins('
          INNER JOIN students ON students.id = meetings.student_id
          LEFT OUTER JOIN monastics ON monastics.id = meetings.monastic_id'
        ).where("meetings.start_date >= ? AND meetings.start_date <=? AND students.first_name=? AND students.last_name=?", report_start_date, report_end_date, @first_name, @last_name).order("meetings.start_date")
      render "reports/student_report.xlsx.axlsx"
    end
  end
end
