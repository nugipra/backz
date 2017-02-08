class Profile < ApplicationRecord
  belongs_to :user
  has_many :backup_files

  validates :name, :backup_paths, presence: true

  def run_backup
    version = (self.latest_backup_version || 0) + 1

    self.backup_paths.split(",").each do |path|
      BackupFile.store(self, path.strip, version)
    end
  end

  def latest_backup_version
    return self.backup_files.maximum("version")
  end

  def excluded?(pathname)
    return false if self.exclusion_paths.blank?
    return self.exclusion_paths.split(",").any?{ |pattern| File.fnmatch(pattern.strip.downcase, pathname.downcase) }
  end

  def count_files_by_status_and_version(status, version)
    return self.backup_files.where(status: status, version: version).count
  end

  def backup_completion_time(version)
    last_file = self.backup_files.where(version: version).last
    return last_file.try(:created_at)
  end

end
