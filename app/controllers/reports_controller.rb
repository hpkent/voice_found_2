class ReportsController < ApplicationController

  def new
  end

  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, params["#{field_name.to_s}(2i)"].to_i, params["#{field_name.to_s}(3i)"].to_i)
  end

  def client_report
    report_start_date = build_date_from_params("start_date", params[:report])
    report_end_date = build_date_from_params("end_date", params[:report])
    @client = params[:Name]
    @client = @client.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '')
    puts @client
    if @client.match(" ")
      #client has two names
      client_array = @client.split(" ")
      @first_name = client_array[0]
      @last_name = client_array[1]
      puts "full name: #{@first_name}"
      @client_sittings_report = Meeting.select('clients.first_name AS client_first_name, managers.initials AS manager_initials').joins('
          INNER JOIN clients ON clients.id = meetings.client_id
          LEFT OUTER JOIN managers ON managers.id = meetings.manager_id'
        ).where("meetings.start_date >= ? AND meetings.start_date <=? AND clients.first_name=? AND clients.last_name=?", report_start_date, report_end_date, @first_name, @last_name).order("meetings.start_date")
      render "reports/client_report.xlsx.axlsx"
    end
  end
end
