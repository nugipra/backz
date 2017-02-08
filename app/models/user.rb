class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :profiles, dependent: :destroy
  has_many :backup_files, through: :profiles

  def storage_usage
    return self.backup_files.sum(:actual_size)
  end

  def count_backup_files_by_filetype(filetype)
    self.backup_files.where(filetype: filetype).where.not(status: "not changed").count
  end

  def generate_total_backup_files_chart_data
    data = {
      labels: [
        " Audio",
        " Video",
        " Image",
        " Text",
        " Other"
      ],
      datasets: [
        {
          data: [
            self.count_backup_files_by_filetype("audio"),
            self.count_backup_files_by_filetype("video"),
            self.count_backup_files_by_filetype("image"),
            self.count_backup_files_by_filetype("text"),
            self.count_backup_files_by_filetype("other")
          ],
          backgroundColor: ["red", "green", "blue", "magenta", "yellow"]
        }
      ]
    }

    return data
  end

  def generate_range_of_size_chart_data
    data = {
      labels: [
        " < 1MB",
        " 1 MB - 10 MB",
        " 10 MB - 100 MB",
        " > 100 MB"
      ],
      datasets: [
        {
          data: [
            self.backup_files.where("size < 1000000").where.not(status: "not changed").count,
            self.backup_files.where("size >= 1000000 AND size <= 10000000").where.not(status: "not changed").count,
            self.backup_files.where("size >= 10000000 AND size <= 100000000").where.not(status: "not changed").count,
            self.backup_files.where("size >= 100000000").where.not(status: "not changed").count
          ],
          backgroundColor: ["red", "green", "blue", "magenta"]
        }
      ]
    }

    return data
  end
end
