class ClientsController < ApplicationController
  require 'date'

  def home
    if session[:sitting_id] != nil
      respond_to do |format|
        format.html { redirect_to("/clients/attendance") }
      end
    else
      respond_to do |format|
        format.html { redirect_to("/sittings/select_sitting") }
      end
    end
  end

  #STUDENT ROUTES
  def attendance
    @sitting_id = session[:sitting_id]
    @sitting = Sitting.find(@sitting_id)
    @sitting_event_title = Sitting.find(@sitting_id).event_title
    @sitting_start_date = Sitting.find(@sitting_id).start_date.strftime("%A, %B %-d, %Y")
    @attendance_status_type_id_scheduled = AttendanceStatusType.where(name: "scheduled").first.id
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    @scheduled_clients = Client.select('clients.id, clients.senority, clients.first_name, clients.last_name, special_status_types.name AS special_status, clients_sittings.id AS clients_sittings_id, clients_sittings.hatto AS hatto, category_types.name AS category_name, category_types.order AS category_order').joins('
      INNER JOIN clients_sittings ON clients_sittings.client_id = clients.id
      INNER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id
      LEFT OUTER JOIN special_status_types ON special_status_types.id = clients_sittings.special_status_type_id
      LEFT OUTER JOIN category_types ON category_types.id = clients.category_type_id'
      ).where("
      clients_sittings.attendance_status_type_id =? AND clients_sittings.sitting_id =?", @attendance_status_type_id_scheduled, @sitting_id).order("category_types.order ASC").order(:senority).order(:first_name)
    @attending_clients = Client.select('clients.id, clients.first_name, clients.last_name, clients.senority, special_status_types.name AS special_status, clients_sittings.id AS clients_sittings_id, clients_sittings.meeting_id AS meeting_id, clients_sittings.hatto AS hatto, category_types.name AS category_name, category_types.order AS category_order').joins('
      INNER JOIN clients_sittings ON clients_sittings.client_id = clients.id
      INNER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id
      LEFT OUTER JOIN special_status_types ON special_status_types.id = clients_sittings.special_status_type_id
      LEFT OUTER JOIN category_types ON category_types.id = clients.category_type_id'
      ).where("
      clients_sittings.attendance_status_type_id =? AND clients_sittings.sitting_id =?", @attendance_status_type_id_present, @sitting_id).order("category_types.order ASC").order(:senority).order(:first_name)

    @clients = Client.all
    @clients_sittings = ClientsSitting.new
    @clients_sittings_loc = ClientsSitting.new
    @all_groups = Group.all
    @clients_groups = ClientsGroup.new
    @note = Note.new
    @current_note = Note.where(id:@sitting.note_id).first

  end

  def autocomplete
    @clients = Client.search_by_name(params[:term]).active_client
    render json: @clients, root: false, each_serializer: AutocompleteSerializer
  end

  def update_clients_sitting_autocomplete
   clients_sitting = ClientsSitting.where(sitting_id:params[:clients_sitting][:sitting_id],client_id:params[:clients_sitting][:client_id]).first_or_initialize
    respond_to do |format|
      if (clients_sitting.update(clients_sitting_params))
        format.html { redirect_to("/clients/attendance") }
      else
        format.html { redirect_to("/clients/attendance") }
      end
    end
  end

  def list_all
    @sitting_id = session[:sitting_id]
    @clients = Client.active_client.order(:first_name)
    @clients_sittings = ClientsSitting.new
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    @attendance_status_type_id_scheduled = AttendanceStatusType.where(name: "scheduled").first.id
  end

  def cancel_attendance
     clients_sittings = ClientsSitting.find(params[:clients_sittings_id])
     clients_sittings.destroy
   respond_to do |format|
      format.html { redirect_to '/clients/attendance' }
      format.json
      format.js
   end
  end

  def schedule_meetings
    @sitting_id = session[:sitting_id]
    @sitting = Sitting.find(@sitting_id)
    @current_note = Note.where(id:@sitting.note_id).first
    @sitting_event_title = Sitting.find(@sitting_id).event_title
    @sitting_start_date = Sitting.find(@sitting_id).start_date.strftime("%A, %B %-d, %Y")
    @attendance_status_type_id_scheduled = AttendanceStatusType.where(name: "scheduled").first.id
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    @attending_clients_search = Client.joins('
      INNER JOIN clients_sittings ON clients_sittings.client_id = clients.id
      INNER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id'
      ).where("
      clients_sittings.attendance_status_type_id =? AND clients_sittings.sitting_id =?",
    @attendance_status_type_id_present, @sitting_id).order("days_since_last_seen DESC")
    @attending_clients_search.each do |s|
      s.calc_last_seen(@sitting_id,s)
    end
    @attending_clients = Client.select('clients.id, clients.first_name, clients.last_name, clients.bench, clients.acceptance_date, clients.date_last_seen, clients.days_since_last_seen, special_status_types.name AS special_status, special_status_types.priority AS special_status_priority, clients_sittings.sitting_id AS sitting_id, clients_sittings.meeting_id AS meeting_id, clients_sittings.hatto AS hatto, category_types.name AS category_name').joins('
      INNER JOIN clients_sittings ON clients_sittings.client_id = clients.id
      INNER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id
      LEFT OUTER JOIN special_status_types ON special_status_types.id = clients_sittings.special_status_type_id
      LEFT OUTER JOIN category_types ON category_types.id = clients.category_type_id'
      ).where("
      clients_sittings.attendance_status_type_id =? AND clients_sittings.sitting_id =?",
    @attendance_status_type_id_present, @sitting_id).where("category_types.name !=? AND category_types.name !=?","Formal", "Manager").order("special_status_types.priority DESC").order("days_since_last_seen DESC").order(:first_name)
    @attending_managers = Client.select('clients.id, clients.first_name, clients.last_name, clients.bench, clients.acceptance_date, clients.date_last_seen, clients.days_since_last_seen, clients.senority, special_status_types.name AS special_status, clients_sittings.sitting_id AS sitting_id, clients_sittings.meeting_id AS meeting_id, clients_sittings.hatto AS hatto, category_types.name AS category_name').joins('
      INNER JOIN clients_sittings ON clients_sittings.client_id = clients.id
      INNER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id
      LEFT OUTER JOIN special_status_types ON special_status_types.id = clients_sittings.special_status_type_id
      LEFT OUTER JOIN category_types ON category_types.id = clients.category_type_id'
      ).where("
      clients_sittings.attendance_status_type_id =? AND clients_sittings.sitting_id =?",
      @attendance_status_type_id_present, @sitting_id).where("category_types.name =? OR category_types.name =?","Formal", "Manager").order(:senority)
  end

  def admin
  end

  def new_dropdown
    @sitting_id = session[:sitting_id]
    @attendance_status_type_id_scheduled = AttendanceStatusType.where(name: "scheduled").first.id
    @group = Group.find(params[:clients_group][:group_id])
    @clients_in_groups = Client.select('clients.id, clients.first_name, clients.last_name, clients_groups.id AS clients_groups_id, groups.name AS group_name, category_types.name AS category_name').joins('
    INNER JOIN clients_groups ON clients_groups.client_id = clients.id
    INNER JOIN groups ON clients_groups.group_id = groups.id
    LEFT OUTER JOIN category_types ON category_types.id = clients.category_type_id'
    ).where("
    groups.id =?", @group.id)
    @clients_sittings = ClientsSitting.new
    @clients = Client.all
    if (@clients_in_groups.each != nil) then
      @clients_in_groups.each do |client|
        @clients_sitting_entry = ClientsSitting.where(sitting_id:@sitting_id, client_id:client.id).first_or_initialize do |ss|
            ss.attendance_status_type_id = @attendance_status_type_id_scheduled
        end
         @clients_sitting_entry.save
      end
    end
    respond_to do |format|
      format.html { redirect_to("/clients/attendance")}
    end
  end

  def update_client_status
    @clients_sittings = ClientsSitting.where(sitting_id:params[:clients_sitting][:sitting_id],client_id:params[:clients_sitting][:client_id]).first_or_initialize
    respond_to do |format|
      if (@clients_sittings.update(clients_sitting_params))
        format.html { redirect_to '/clients/attendance' }
        format.json
        format.js
      else
        format.html { redirect_to("/clients/attendance")}
      end
    end
  end

  def update_location_status
    @clients_sittings_loc = ClientsSitting.where(sitting_id:params[:clients_sitting][:sitting_id],client_id:params[:clients_sitting][:client_id]).first_or_initialize
    respond_to do |format|
      if (@clients_sittings_loc.update(clients_sitting_params))
        format.html { redirect_to '/clients/attendance' }
        format.json
        format.js
      else
        format.html { redirect_to("/clients/attendance")}
      end
    end
  end

  def update_list_all_client
    @clients_sitting = ClientsSitting.where(sitting_id:params[:clients_sitting][:sitting_id],client_id:params[:clients_sitting][:client_id]).first_or_initialize
    respond_to do |format|
      if (@clients_sitting.update(clients_sitting_params))
        format.html { redirect_to("/clients/list_all") }
        format.json
        format.js
      else
        format.html { redirect_to("/clients/list_all") }
      end
    end
  end

# def js_add_client_to_sitting

#   clients_sitting = ClientsSitting.where(sitting_id:params[:sitting_id],client_id:params[:client_id]).first_or_initialize
#   ast_id = AttendanceStatusType.where(name:"present").first.id

#     respond_to do |format|
#       format.js
#     end

# end

#SPECIAL STATUS METHODS

  def new_special_status
    @sitting_id = session[:sitting_id]
    @client_id = params[:client_id]
    @client = Client.find(@client_id)
    @clients_sittings = ClientsSitting.new
  end

  def update_special_status
    clients_sitting = ClientsSitting.where(sitting_id:params[:clients_sitting][:sitting_id],client_id:params[:clients_sitting][:client_id]).first_or_initialize
    respond_to do |format|
      if (clients_sitting.update(clients_sitting_params))
        format.html { redirect_to("/clients/attendance/")}
      else
        format.html { redirect_to("/clients/attendance/")}
      end
    end
  end

  def update_location
    clients_sitting = ClientsSitting.where(sitting_id:params[:clients_sitting][:sitting_id],client_id:params[:clients_sitting][:client_id]).first_or_initialize
    respond_to do |format|
      if (clients_sitting.update(clients_sitting_params))
        format.html { redirect_to("/clients/attendance/")}
      else
        format.html { redirect_to("/clients/attendance/")}
      end
    end
  end

  # STUDENT ACTIONS
  def manage_clients
    @clients = Client.active_client.order(:category_type_id).order(:first_name)
  end

  def manage_inactive_clients
    @clients = Client.inactive_client.order(:first_name)
  end

  def manage_absent_clients
    @clients = Client.absent_client.order(:first_name)
  end

  def new
    @client = Client.new
  end

  def history
    @client_id = params[:id]
    @client = Client.find(@client_id)

    @show_meetings = Meeting.select('meetings.start_date, meetings.client_id, sittings.event_title AS event_title, managers.initials AS initials').joins('
      INNER JOIN clients ON clients.id = meetings.client_id
      LEFT OUTER JOIN managers ON managers.id = meetings.manager_id
      LEFT OUTER JOIN sittings ON sittings.id = meetings.sitting_id'
      ).where("
      meetings.client_id =?", @client).order("start_date DESC").limit(10)
  end

  def edit
    @client = Client.find(params[:id])
  end

  def create
    @client = Client.new(client_params).first_or_initialize
    if @client.save
      redirect_to @client
    else
      render 'new'
    end
  end

  def update
    @client = Client.where(id:params[:id]).first_or_initialize
    if @client.update(client_params)
      redirect_to clients_manage_clients_path
    else
      render 'edit'
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_manage_clients_path
  end

  private
    def client_params
      params.require(:client).permit(:first_name, :last_name, :category_type_id, :acceptance_date, :email, :dietary_restrictions, :other, :bench)
    end

    def clients_sitting_params
      params.require(:clients_sitting).permit(:sitting_id, :client_id, :attendance_status_type_id, :special_status_type_id, :meeting_id, :hatto)
    end
end


