class LocationType < ActiveRecord::Base
  has_many :clients_sittings
end
