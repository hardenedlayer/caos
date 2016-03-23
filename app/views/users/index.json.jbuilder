json.array!(@users) do |user|
  json.extract! user, :id, :mail, :name, :comment, :password_at, :perms
  json.url user_url(user, format: :json)
end
