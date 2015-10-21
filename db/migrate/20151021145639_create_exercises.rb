class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.timestamp :start
      t.timestamp :end
      t.integer :code
      t.integer :week_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
