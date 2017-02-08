class AddFiletypeToBackupFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :backup_files, :filetype, :string
  end
end
