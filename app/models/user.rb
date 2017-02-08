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
end
