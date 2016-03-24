json.array!(@albums) do |album|
  json.extract! album, :id, :title, :username, :api_key, :network, :datacenter, :container, :user_id
  json.url album_url(album, format: :json)
end
