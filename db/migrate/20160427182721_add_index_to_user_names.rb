class AddIndexToUserNames < ActiveRecord::Migration
  def change
    add_index :users, :last_name
    add_index :users, :first_name
  end
end
