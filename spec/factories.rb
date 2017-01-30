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
end