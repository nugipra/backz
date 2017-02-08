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
    access_number = permission.present? ? sprintf("%o", permission) : nil

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
      dirname = backup_file.storage_path
      FileUtils.mkdir_p dirname, mode: stat.mode

      Dir.entries(path).each do |child|
        next if child == "." || child == ".."

        child_path = Pathname.new(path).join(child).to_s
        BackupFile.store(profile, child_path, version, backup_file)
      end
    else
      backup_file.last_modified = File.mtime(path)

      # avoid data deduplication if file is not changed
      # create symlink instead of storing identical file
      versioned_file_storage_path = backup_file.storage_path(version: version - 1)
      file_storage_path = backup_file.storage_path
      if File.exists?(versioned_file_storage_path) && FileUtils.compare_file(versioned_file_storage_path, path)
        backup_file.status = "not changed"
        File.symlink File.realpath(versioned_file_storage_path), file_storage_path
      else
        backup_file.status = File.exists?(versioned_file_storage_path) ? "modified" : "added"
        FileUtils.cp path, File.dirname(file_storage_path), preserve: true
      end
      backup_file.actual_size = File.lstat(file_storage_path).size
      backup_file.set_filetype

      backup_file.save
    end
  end

  def storage_path(options = {})
    version = options[:version].present? ?  options[:version] : self.version
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

  def revisions
    return BackupFile.where(profile_id: self.profile_id, where: self.where, filename: self.filename).where.not(status: 'not changed').order("created_at desc")
  end

  def newest_revision
    return self.revisions.first
  end

  def description_of_the_contents
    begin
      fm = FileMagic.new(FileMagic::MAGIC_MIME)
      return fm.file(File.realpath(self.storage_path))
    ensure
      fm.close
    end
  end

  def text?
    return !(self.description_of_the_contents =~ /^text\//).nil?
  end

  def image?
    return !(self.description_of_the_contents =~ /^image\//).nil?
  end

  def video?
    return !(self.description_of_the_contents =~ /^video\//).nil?
  end

  def audio?
    return !(self.description_of_the_contents =~ /^audio\//).nil?
  end

  def set_filetype
    type = "other"
    type = "text" if text?
    type = "image" if image?
    type = "video" if video?
    type = "audio" if audio?

    self.filetype = type
  end

  def owner_name
    return Etc.getpwuid(self.uid).try(:name)
  end

  def group_name
    return Etc.getgrgid(self.gid).try(:name)
  end

  def restore(version)
    filepath = self.storage_path
    restored_file_storage_path = self.storage_path(version: version)
    last_version_file_storage_path = self.storage_path(version: self.version - 1)

    FileUtils.rm filepath
    if FileUtils.compare_file(restored_file_storage_path, last_version_file_storage_path)
      self.status = "not changed"
      File.symlink File.realpath(last_version_file_storage_path), filepath
    else
      self.status = "modified"
      FileUtils.cp restored_file_storage_path, File.dirname(filepath), preserve: true
    end
    self.last_modified = Time.now
    self.size = File.size(filepath)
    self.actual_size = File.lstat(filepath).size
    self.set_filetype
    self.save
  end
end