class BackupFile < ApplicationRecord
  belongs_to :profile
  belongs_to :parent, class_name: "BackupFile", foreign_key: :parent_id, required: false
  has_many :children, class_name: "BackupFile", foreign_key: :parent_id

  BACKUP_DATA_FOLDER_NAME = ".backupdata"

  # all backup files will be stored here
  def self.base_dir
    return Rails.root.join(BACKUP_DATA_FOLDER_NAME, Rails.env)
  end

  def self.store(profile, path, version, parent = nil)
    return unless File.exists?(path) && (File.file?(path) || File.directory?(path))
    return unless not profile.excluded?(path)

    # extract file information
    stat = File.stat(path)
    permission = stat.world_readable?
    filename = File.basename(path)
    access_number = sprintf("%o", permission)

    backup_file = BackupFile.new(
      profile_id: profile.id,
      version: version,
      where: parent.nil? ? "" : parent.relative_path,
      filename: filename,
      is_directory: File.directory?(path),
      size: File.size(path),
      mode: stat.mode,
      access_number: access_number,
      gid: stat.gid,
      uid: stat.uid,
      parent_id: parent.try(:id)
    )
 
    # backup actual files
    if File.directory?(path)
      backup_file.save
      dirname = backup_file.get_storage_path_by_version(version)
      FileUtils.mkdir_p dirname, mode: stat.mode

      Dir.entries(path).each do |child|
        next if child == "." || child == ".."

        child_path = Pathname.new(path).join(child).to_s
        BackupFile.store(profile, child_path, version, backup_file)
      end
    else
      # avoid data deduplication if file is not changed
      # create symlink instead of storing identical file
      versioned_file_storage_path = backup_file.get_storage_path_by_version(version - 1)
      file_storage_path = backup_file.get_storage_path_by_version(version)
      if File.exists?(versioned_file_storage_path) && FileUtils.compare_file(versioned_file_storage_path, path)
        backup_file.status = "not changed"
        File.symlink File.realpath(versioned_file_storage_path), file_storage_path
      else
        backup_file.status = File.exists?(versioned_file_storage_path) ? "modified" : "added"
        FileUtils.cp path, File.dirname(file_storage_path)
      end

      backup_file.save
    end
  end

  def get_storage_path_by_version(version)
    return "" if version.blank? || version.to_i.zero?

    # backup records will be grouped under profile and version folder
    dir = BackupFile.base_dir.join("%06d" % self.profile_id, "%06d" % version)
    FileUtils.mkdir_p dir

    return dir.join(self.relative_path).to_s 
  end

  def parents
    res = []
    current_parent = self
    while current_parent.try(:parent_id).present?
      current_parent = current_parent.parent
      res.push(current_parent)
    end
    return res
  end

  def self_and_parents
    return [self] + self.parents
  end

  def relative_path
    return Pathname.new(self.where.to_s).join(self.filename).to_s
  end
end
