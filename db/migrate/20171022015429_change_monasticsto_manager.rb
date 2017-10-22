class ChangeMonasticstoManager < ActiveRecord::Migration
  def change
    rename_table :monastics, :managers
  end
end
