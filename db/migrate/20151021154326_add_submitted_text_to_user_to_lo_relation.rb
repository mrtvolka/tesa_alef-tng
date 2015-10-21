class AddSubmittedTextToUserToLoRelation < ActiveRecord::Migration
  def change
    add_column :user_to_lo_relations, :submitted_text, :text
  end
end
