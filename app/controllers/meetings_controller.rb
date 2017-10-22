class MeetingsController < ApplicationController

  # MEETING METHODS
  def new
    @sitting_id = session[:sitting_id]
    @sitting_start_date = Sitting.find(@sitting_id).start_date
    @sitting_start_time = Sitting.find(@sitting_id).start_time
    @client_id = params[:client_id]
    @client = Client.find(@client_id)
    @meeting = Meeting.new
    @regular_meeting_type = MeetingType.where(name:"regular").first.id
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    @show_meetings = Meeting.select('meetings.start_date, meetings.client_id, sittings.event_title AS event_title, managers.initials AS initials').joins('
      INNER JOIN clients ON clients.id = meetings.client_id
      LEFT OUTER JOIN managers ON managers.id = meetings.manager_id
      LEFT OUTER JOIN sittings ON sittings.id = meetings.sitting_id'
      ).where("
      meetings.client_id =? AND meetings.start_time !=?", @client, @sitting_start_time).order("start_date DESC").limit(10)
    @show_attendance = ClientsSitting.select('clients_sittings.client_id, sittings.event_title AS event_title, sittings.start_date AS start_date, attendance_status_types.id AS attendance_status_type').joins('
    LEFT OUTER JOIN sittings ON sittings.id = clients_sittings.sitting_id
    LEFT OUTER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id'
    ).where("
    clients_sittings.client_id =? AND sittings.start_time !=? AND clients_sittings.attendance_status_type_id=?", @client, @sitting_start_time, @attendance_status_type_id_present).order("start_date DESC").limit(10)
  end

  def update
    meeting = Meeting.where(client_id:params[:meeting][:client_id], manager_id:params[:meeting][:manager_id], meeting_type_id:params[:meeting][:meeting_type_id]).first_or_initialize
      meeting = params[:meeting]
      start_date_params = Date.new meeting["start_date(1i)"].to_i, meeting["start_date(2i)"].to_i, meeting["start_date(3i)"].to_i
      m = Meeting.where(start_date:start_date_params, start_time:start_date_params, client_id:params[:meeting][:client_id], manager_id:params[:meeting][:manager_id], meeting_type_id:params[:meeting][:meeting_type_id]).first_or_initialize
      respond_to do |format|
        if (m.update(meeting_params))
          format.html { redirect_to("/meetings/show_other") }
        else
          format.html { redirect_to("/meetings/show_other") }
        end
      end
  end

  def destroy
    clients_sitting = ClientsSitting.where(meeting_id:params[:meeting_id]).first_or_initialize
    clients_sitting.meeting = nil
    clients_sitting.save
    meeting = Meeting.find(params[:meeting_id])
    meeting.destroy
    redirect_to '/clients/schedule_meetings/'
  end

  def show_other
    @other_meetings = Meeting.select('meetings.start_date, meetings.client_id, meetings.id, meetings.meeting_type_id, meetings.duration, clients.first_name AS first_name, clients.last_name AS last_name, managers.id AS manager_id, managers.title AS manager_title, managers.first_name AS manager_first_name, managers.last_name AS manager_last_name').joins('
      INNER JOIN clients ON clients.id = meetings.client_id
      LEFT OUTER JOIN managers ON managers.id = meetings.manager_id'
      ).order("start_date DESC")
  end

  def new_other_meeting
    @other_meeting = Meeting.new
  end

  def autocomplete
    @clients = Client.search_by_name(params[:term]).active_client
    render json: @clients, root: false, each_serializer: AutocompleteSerializer
  end

  def edit_other_meeting
    @other_meeting = Meeting.find(params[:meeting_id])
    @client_id = @other_meeting.client_id
    @client = Client.find(@client_id)
  end

  def delete_other_meeting
    @other_meeting = Meeting.find(params[:meeting_id])
    @other_meeting.destroy
    respond_to do |format|
      format.html { redirect_to '/meetings/show_other' }
      format.json
      format.js
    end
  end

  private
    def meeting_params
      params.require(:meeting).permit(:manager_id, :note_id, :sitting_id, :client_id, :start_date, :start_time, :meeting_type_id, :partner_id, :duration)
    end
end

