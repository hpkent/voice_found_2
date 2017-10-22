class ClientsGroup < ActiveRecord::Base
  belongs_to :client
  belongs_to :group
end
