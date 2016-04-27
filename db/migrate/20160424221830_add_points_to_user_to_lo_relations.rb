class AddPointsToUserToLoRelations < ActiveRecord::Migration
  def change
    add_column :user_to_lo_relations, :points, :real
  end
end
