class Client < ActiveRecord::Base
  has_many :clients_sittings
  has_many :sittings, through: :clients_sittings
  has_many :meetings
  has_many :clients_groups
  belongs_to :category_type
  scope :search_by_name, lambda { |q|
   (q ? where(["first_name LIKE ? or last_name LIKE ? or concat(first_name, ' ', last_name) like ?", '%'+ q + '%', '%'+ q + '%','%'+ q + '%' ])  : {})
  }

  def calc_last_seen(sitting_id,s)
    @sitting = Sitting.find(sitting_id)
    now = @sitting.start_date
    @default_date = now
    # @attending_clients.each do |s|
      # m = s.meetings.where('meetings.start_date!=?',Date.today)
    m = s.meetings.where('meetings.start_time!=?',@sitting.start_time)
    if m.length == 0 then
      # Client.find(s.id).update(:date_last_seen => @default_date)
      # Client.find(s.id).update(:days_since_last_seen => (now - @default_date).to_i)
      # puts "test test: #{s.meetings.length}"
    elsif m.length > 0
       s.date_last_seen = m.order('start_date DESC').first.start_date
       Client.find(s.id).update(:date_last_seen => s.date_last_seen)
       Client.find(s.id).update(:days_since_last_seen => (now - s.date_last_seen).to_i)
       puts "test test: #{s.meetings.length}"
    end
  end

  def calc_last_attended(client)
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    client_sitting = ClientsSitting.joins('
    LEFT OUTER JOIN sittings ON sittings.id = clients_sittings.sitting_id
    LEFT OUTER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id'
    ).where("
    clients_sittings.client_id =? AND clients_sittings.attendance_status_type_id=?", client, @attendance_status_type_id_present).order('sittings.start_date DESC').first
    if client_sitting != nil
      last_sitting_id = client_sitting.sitting_id
      last_sitting_date = Sitting.find(last_sitting_id).start_date
      puts "client: #{client.first_name} last_sitting: #{last_sitting_date}"
      last_sitting_date
    end
  end

  def calc_wrong_category(client)
    @attendance_status_type_id_present = AttendanceStatusType.where(name: "present").first.id
    client_sitting = ClientsSitting.joins('
    LEFT OUTER JOIN sittings ON sittings.id = clients_sittings.sitting_id
    LEFT OUTER JOIN attendance_status_types ON attendance_status_types.id = clients_sittings.attendance_status_type_id'
    ).where("
    clients_sittings.client_id =? AND clients_sittings.attendance_status_type_id=?", client, @attendance_status_type_id_present).order('sittings.start_date DESC').first
    #nil result returned if client likely in wrong category
    client_sitting
  end

  def self.active_client

    @inactive_client = Client.all
  end

  def self.inactive_client

    @inactive_client = Client.all
  end

  def self.absent_client
    @absent_client = Client.all
  end
end
