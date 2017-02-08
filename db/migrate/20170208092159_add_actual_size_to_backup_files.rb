class AddActualSizeToBackupFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :backup_files, :actual_size, :integer
  end
end
