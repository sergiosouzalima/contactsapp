json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :email, :birthdate, :phone_number
  json.url contact_url(contact, format: :json)
end
