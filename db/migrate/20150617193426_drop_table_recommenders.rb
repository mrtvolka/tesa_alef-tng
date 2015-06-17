class DropTableRecommenders < ActiveRecord::Migration
  def change
    remove_column :recommenders_options, :recommender_id
    drop_table :recommenders
    add_column :recommenders_options, :recommender_name, :string
  end
end
