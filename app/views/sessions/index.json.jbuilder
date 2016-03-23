json.array!(@sessions) do |session|
  json.extract! session, :id, :user_id, :login_at, :logout_at
  json.url session_url(session, format: :json)
end
