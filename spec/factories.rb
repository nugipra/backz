FactoryGirl.define do
  factory :user do
    email                 Faker::Internet.email
    password              "password"
    password_confirmation "password"
  end

  factory :profile do
    user
    name            "First Profile"
    backup_paths    "/home/ubuntu/backup, /home/test, /var/sys/log"
    exclusion_paths ".ssh, /home/ubuntu/exclude, /var/sys/sensitive, .gitignore, *.dmg"
  end

  factory :backup, class: BackupFile do
    profile
    version 1
    gid 20
    uid 501
    where ""

    transient do
      folder nil
    end

    factory :backup_folder do
      is_directory true
      sequence :filename do |n|
        "folder#{n}"
      end
    end

    factory :backup_file do
      is_directory false
      sequence :filename do |n|
        "file#{n}.rb"
      end
    end

    before(:create) do |backup, evaluator|
      if evaluator.folder.present?
        backup.parent_id = evaluator.folder.id
        backup.where = evaluator.folder.relative_path
      end
    end

    after(:create) do |backup|
      if backup.is_directory
        FileUtils.mkdir_p backup.storage_path
      else
        FileUtils.touch backup.storage_path
      end
    end
  end

end