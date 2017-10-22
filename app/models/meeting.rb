class Meeting < ActiveRecord::Base
  has_one :clients_sitting
  belongs_to :manager
  has_many :notes
  belongs_to :client
  belongs_to :meeting_types
  belongs_to :partner
end
