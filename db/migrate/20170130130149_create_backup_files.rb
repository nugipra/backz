class CreateBackupFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :backup_files do |t|
      t.references :profile, foreign_key: true
      t.integer :version
      t.string :where
      t.string :filename
      t.boolean :is_directory
      t.integer :access_number
      t.integer :mode
      t.integer :gid
      t.integer :uid
      t.integer :size
      t.string :status
      t.datetime :file_created_at
      t.datetime :file_modified_at
      t.integer :parent_id

      t.timestamps
    end
  end
end
