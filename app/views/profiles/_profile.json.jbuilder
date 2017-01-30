json.extract! profile, :id, :user_id, :name, :backup_paths, :exclusion_paths, :created_at, :updated_at
json.url profile_url(profile, format: :json)