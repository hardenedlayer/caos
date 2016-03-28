json.array!(@selections) do |selection|
  json.extract! selection, :id, :user_id, :album_id, :photos
  json.url selection_url(selection, format: :json)
end
