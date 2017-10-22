class AttendanceStatusType < ActiveRecord::Base
  has_many :clients_sittings
end
