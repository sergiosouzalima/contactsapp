namespace :text_file do
  # Examples:
  # rake text_file:seed
  # ---
  # text files will be stored at contactapp/db
  #
  desc "Seeds text file with random data."
  task :seed => [:environment] do
    puts "####### deleting text file"
    filepath = "db/#{Rails.env}.txt"
    File.delete(filepath) if File.exists?(filepath)
    Contact.filepath = filepath

    (1..1000).each do |e|
      puts "####### creating contact #{e}"
      Contact.new( name: Faker::Name.name, email: Faker::Internet.email,
                  birthdate: Faker::Date.backward(18250).to_s,
                  phone_number: Faker::PhoneNumber.phone_number ).save
    end
    puts "####### done."
  end

end
