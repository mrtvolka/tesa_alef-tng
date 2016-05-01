class AddScoringTypeToSetups < ActiveRecord::Migration
  def change
    add_column :setups, :scoring_type, :string
  end
end
