class Profile < ApplicationRecord
  belongs_to :user

  validates :name, :backup_paths, presence: true
end
