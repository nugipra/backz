class RemoveFileCreatedAt < ActiveRecord::Migration[5.0]
  def change
    remove_column :backup_files, :file_created_at, :datetime

    # better naming
    rename_column :backup_files, :file_modified_at, :last_modified
  end
end
