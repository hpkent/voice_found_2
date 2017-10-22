class Manager < ActiveRecord::Base
  has_many :meetings
    def manager_name
      "#{self.title} #{self.first_name} #{self.last_name}"
    end
end
