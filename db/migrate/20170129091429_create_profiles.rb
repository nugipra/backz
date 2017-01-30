class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :backup_paths
      t.string :exclusion_paths

      t.timestamps
    end
  end
end
