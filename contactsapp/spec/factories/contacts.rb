FactoryGirl.define do
  factory :contact do
    name "John Smith"
    email "john_smith@gmail.net"
    birthdate "2000-07-01"
    phone_number "1111-2222"
    deleted "N"
  end
  initialize_with do
    new(attributes)
  end
end
