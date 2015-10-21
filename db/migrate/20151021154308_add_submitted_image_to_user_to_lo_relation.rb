class AddSubmittedImageToUserToLoRelation < ActiveRecord::Migration
  def change
    add_column :user_to_lo_relations, :submitted_image, :binary
  end
end
