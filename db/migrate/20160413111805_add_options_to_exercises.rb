class AddOptionsToExercises < ActiveRecord::Migration
  def change
    enable_extension :hstore
    add_column :exercises, :options, :hstore
  end
end
