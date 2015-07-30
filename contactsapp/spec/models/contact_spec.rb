require "rails_helper"

RSpec.describe Contact, :type => :model do

  before :all do
    @name            = 'John Smith'
    @email           = 'john_smith@gmail.net'
    @birthdate       = '2000-07-01'
    @phone_number    = '1111-2222'
    @deleted         = Contact::DELETED_OPTIONS[1] # 'N'
    @rspec_file_path = 'db/test.txt'
    @rspec_file_path2 = "db/test2.txt"
    delete_file
    Contact.filepath = @rspec_file_path
  end

  after :all do
    delete_file
    delete_file( @rspec_file_path2 )
  end

  def delete_file( file = @rspec_file_path )
    File.delete(file) if File.exists?(file)
  end

  context 'attributes content validation' do
    context 'when valid content' do
      describe "and creating a new Contact instance" do
        contact = Contact.new
        it "new instance is a Contact class" do
          expect(contact).to be_kind_of(Contact)
        end
      end
      describe "and all attributes are correct" do
        contact = FactoryGirl.build :contact
        it "returns valid? true" do
          expect(contact.valid?).to be_truthy
        end
        it "returns no error messages" do
          expect(contact.errors.messages.empty?).to be_truthy
        end
      end
    end
    context 'when invalid content' do
      describe "and creating a new Contact instance" do
        contact = FactoryGirl.build :contact, name: nil, email: nil, birthdate: nil, deleted: nil
        it "new instance is a Contact class" do
          expect(contact).to be_kind_of(Contact)
        end
      end
      describe "and one of the attributes are incorrect" do
        contact = FactoryGirl.build :contact, name: nil
        it "returns valid? false" do
          expect(contact.valid?).to be_falsey
        end
        it "returns error messages" do
          expect(contact.errors.messages.empty?).to be_falsey
        end
      end
      describe "and name is empty" do
        contact = FactoryGirl.build :contact, name: nil
        it "returns 'cant be blank' error message" do
          contact.valid?
          expect(contact.errors.messages[:name][0]).to eq "can't be blank"
        end
      end
      describe "and name is too large" do
        contact = FactoryGirl.build :contact, name: 'x' * 51
        it "returns 'too long' error message" do
          contact.valid?
          expect(contact.errors.messages[:name][0]).to eq "is too long (maximum is 50 characters)"
        end
      end
      describe "and email is invalid" do
        contact = FactoryGirl.build :contact, email: 'John Smith@net'
        it "returns 'is invalid' error message" do
          contact.valid?
          expect(contact.errors.messages[:email][0]).to eq "is invalid"
        end
      end
      describe "and date of birth is invalid" do
        contact = FactoryGirl.build :contact, birthdate: '1966-02-32'
        it "returns 'invalid birthdate' error message" do
          contact.valid?
          expect(contact.errors.messages[:birthdate][0]).to eq "invalid birthdate"
        end
      end
      describe "and phone number is invalid" do
        contact = FactoryGirl.build :contact, phone_number: '1' * 31
        it "returns 'too large' error message" do
          contact.valid?
          expect(contact.errors.messages[:phone_number][0]).to eq "is too long (maximum is 30 characters)"
        end
      end
      describe "and deleted is invalid" do
        contact = FactoryGirl.build :contact, deleted: 'x'
        it "returns 'invalid value' error message" do
          contact.valid?
          expect(contact.errors.messages[:deleted][0]).to eq "is not included in the list"
        end
      end
    end
  end

  context 'file path validation' do
    context 'when valid content' do
      describe "and creating a new Contact instance" do
        before :each do
          Contact.new
        end
        it "returns a String class" do
          expect(Contact.filepath).to be_kind_of(String)
        end
        it "returns db/test.txt" do
          expect(Contact.filepath).to eq "db/test.txt"
        end
      end
      describe "and file path changing" do
        before :each do
          delete_file
          Contact.new
          Contact.filepath = @rspec_file_path2
        end
        it "returns a String class" do
          expect(Contact.filepath).to be_kind_of(String)
        end
        it "returns db/test2.txt" do
          expect(Contact.filepath).to eq @rspec_file_path2
        end
        it "file is created" do
          file_exists = File.exist?(Contact.filepath)
          expect(file_exists).to be_truthy
        end
        after :context do
          Contact.filepath = @rspec_file_path
          delete_file
        end
      end
    end
  end

  context '#find by name validation' do
    context 'when invalid content' do
      before :each do
        delete_file
      end
      describe "and paramater wasn't given" do
        it "returns an empty array" do
          expect(Contact.find_by_name.empty?).to be_truthy
        end
      end
      describe "and file path doesn't exist" do
        it "returns an empty array" do
          expect(Contact.find_by_name('John').empty?).to be_truthy
        end
      end
      describe "and name doesn't exist" do
        before :each do
          delete_file
          FactoryGirl.create(:contact)
        end
        it "returns an empty array" do
          expect(Contact.find_by_name('Mariangela')).to be_empty
          expect(Contact.find_by_name('')).to be_empty
          expect(Contact.find_by_name(9)).to be_empty
        end
      end
    end
    context 'when valid content' do
      describe "and file path exists" do
        before :each do
          delete_file
          FactoryGirl.create(:contact)
        end
        it "returns an Array" do
          expect(Contact.find_by_name('John Smith')).to be_kind_of(Array)
        end
        it "returns an Array of Contact kind" do
          contact = Contact.find_by_name('John Smith')
          expect(contact[0]).to be_kind_of(Contact)
        end
        it "returns an Array of Contact kind, with correct attributes" do
          contact = Contact.find_by_name('John Smith')
          expect(contact[0].name).to         eq @name
          expect(contact[0].email).to        eq @email
          expect(contact[0].birthdate).to    eq @birthdate
          expect(contact[0].phone_number).to eq @phone_number
          expect(contact[0].deleted).to      eq @deleted
        end
        it "returns correct attributes when finding for the second record" do
          name            = 'Maria'
          email           = 'maria@net.net'
          birthdate       = '1968-11-22'
          phone_number    = '2222-1111'
          deleted         = Contact::DELETED_OPTIONS[1]
          contact = Contact.new( name: name,
                                email: email,
                                birthdate: birthdate,
                                phone_number: phone_number )
          contact.save
          second_contact = Contact.find_by_name('Maria')
          expect(second_contact[0].name).to         eq name
          expect(second_contact[0].email).to        eq email
          expect(second_contact[0].birthdate).to    eq birthdate
          expect(second_contact[0].phone_number).to eq phone_number
          expect(second_contact[0].deleted).to      eq deleted
        end
      end
    end
    describe "and there's only one & deleted contact" do
      before :each do
        delete_file
        FactoryGirl.create(:contact, name: 'Sue Hellen', deleted: 'Y')
      end
      it "returns an Array" do
        expect(Contact.find_by_name('Sue Hellen')).to be_kind_of(Array)
      end
      it "returns an empty Array" do
        expect(Contact.find_by_name('Sue Hellen').empty?).to be_truthy
      end
    end
    describe "and there's a deleted & other not deleted contact" do
      before :each do
        delete_file
        FactoryGirl.create :contact
        FactoryGirl.create(:contact, name: 'Sue Hellen', deleted: 'Y')
      end
      it "returns an Array" do
        expect(Contact.find_by_name('John Smith')).to be_kind_of(Array)
      end
      it "returns an Array with just one element" do
        expect(Contact.find_by_name('John Smith').length).to be_truthy
      end
    end
  end

  context '#all validation' do
    context 'when valid content' do
      describe "and no parameter was given" do
        before :each do
          delete_file
          @name_01 = 'John Smith'; @email_01 = 'john_smith@gmail.net'; @bdate_01 = '2000-07-01'; @phone_01 = '1111-2222'
          @name_02 = 'Maria' ; @email_02 = 'maria@net.net' ; @bdate_02 = '1976-11-22'; @phone_02 = '2111-1111'
          @name_03 = 'Ana'   ; @email_03 = 'ana@net.net'   ; @bdate_03 = '1968-11-22'; @phone_03 = '3111-1111'
          @contact_01 = Contact.new( name: @name_01, email: @email_01, birthdate: @bdate_01, phone_number: @phone_01 )
          @contact_01.save
          @contact_02 = Contact.new( name: @name_02, email: @email_02, birthdate: @bdate_02, phone_number: @phone_02 )
          @contact_02.save
          @contact_03 = Contact.new( name: @name_03, email: @email_03, birthdate: @bdate_03, phone_number: @phone_03 )
          @contact_03.save
        end
        it "returns an Array" do
          expect(Contact.all).to be_kind_of(Array)
        end
        it "returns an Array filled with 3 records" do
          expect(Contact.all.length).to eq 3
        end
        it "returns an Array of Contact kind" do
          contacts = Contact.all
          expect(contacts[0]).to be_kind_of(Contact)
          expect(contacts[1]).to be_kind_of(Contact)
          expect(contacts[2]).to be_kind_of(Contact)
        end
        it "returns a 3 records Array of Contact kind, with correct attributes" do
          contacts = Contact.all
          expect(Regexp.new(contacts[0].id)).to be_kind_of(Regexp)
          expect(contacts[0].name).to         eq @name_01
          expect(contacts[0].email).to        eq @email_01
          expect(contacts[0].birthdate).to    eq @bdate_01
          expect(contacts[0].phone_number).to eq @phone_01
          expect(Regexp.new(contacts[1].id)).to be_kind_of(Regexp)
          expect(contacts[1].name).to         eq @name_02
          expect(contacts[1].email).to        eq @email_02
          expect(contacts[1].birthdate).to    eq @bdate_02
          expect(contacts[1].phone_number).to eq @phone_02
          expect(Regexp.new(contacts[2].id)).to be_kind_of(Regexp)
          expect(contacts[2].name).to         eq @name_03
          expect(contacts[2].email).to        eq @email_03
          expect(contacts[2].birthdate).to    eq @bdate_03
          expect(contacts[2].phone_number).to eq @phone_03
        end
      end
    end
  end

  context '#find validation' do
    context 'when invalid content' do
      describe "and file path doesn't exist" do
        before :each do
          delete_file
        end
        it "returns an empty Array" do
          expect(Contact.find.empty?).to be_truthy
        end
      end
      describe "and record number doesn't exist" do
        before :each do
          delete_file
          FactoryGirl.create(:contact)
        end
        it "returns nil" do
          expect(Contact.find(0)).to be_nil
          expect(Contact.find(-1)).to be_nil
          expect(Contact.find(999999999)).to be_nil
        end
      end
    end
    context 'when valid content' do
      describe "and no parameter was given" do
        before :each do
          delete_file
          @name_01 = 'John Smith'; @email_01 = 'john_smith@gmail.net'; @bdate_01 = '2000-07-01';
          @phone_01 = '1111-2222'; @deleted_01 = Contact::DELETED_OPTIONS[1]
          @name_02 = 'Maria';      @email_02 = 'maria@net.net';        @bdate_02 = '1976-11-22';
          @phone_02 = '2111-1111'; @deleted_02 = Contact::DELETED_OPTIONS[1]
          @name_03 = 'Ana';        @email_03 = 'ana@net.net';          @bdate_03 = '1968-11-22';
          @phone_03 = '3111-1111'; @deleted_03 = Contact::DELETED_OPTIONS[1]
          @contact_01 = Contact.new( name: @name_01, email: @email_01, birthdate: @bdate_01, phone_number: @phone_01 )
          @contact_01.save
          @contact_02 = Contact.new( name: @name_02, email: @email_02, birthdate: @bdate_02, phone_number: @phone_02 )
          @contact_02.save
          @contact_03 = Contact.new( name: @name_03, email: @email_03, birthdate: @bdate_03, phone_number: @phone_03 )
          @contact_03.save
        end
        it "returns an Array" do
          expect(Contact.find).to be_kind_of(Array)
        end
        it "returns an Array filled with 3 records" do
          expect(Contact.find.length).to eq 3
        end
        it "returns an Array of Contact kind" do
          contacts = Contact.find
          expect(contacts[0]).to be_kind_of(Contact)
          expect(contacts[1]).to be_kind_of(Contact)
          expect(contacts[2]).to be_kind_of(Contact)
        end
        it "returns a 3 records Array of Contact kind, with correct attributes" do
          contacts = Contact.find
          expect(Regexp.new(contacts[0].id)).to be_kind_of(Regexp)
          expect(contacts[0].name).to           eq @name_01
          expect(contacts[0].email).to          eq @email_01
          expect(contacts[0].birthdate).to      eq @bdate_01
          expect(contacts[0].phone_number).to   eq @phone_01
          expect(contacts[0].deleted).to        eq @deleted_01
          expect(contacts[1].name).to           eq @name_02
          expect(contacts[1].email).to          eq @email_02
          expect(contacts[1].birthdate).to      eq @bdate_02
          expect(contacts[1].phone_number).to   eq @phone_02
          expect(contacts[1].deleted).to        eq @deleted_02
          expect(contacts[2].name).to           eq @name_03
          expect(contacts[2].email).to          eq @email_03
          expect(contacts[2].birthdate).to      eq @bdate_03
          expect(contacts[2].phone_number).to   eq @phone_03
          expect(contacts[2].deleted).to        eq @deleted_03
        end
      end
      describe "and an id was given" do
        before :each do
          delete_file
          FactoryGirl.create(:contact)
          @id = nil
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              @id = line.split(";")[0]
            end
          end
        end
        it "returns a Contact object" do
          expect(Contact.find(@id)).to be_kind_of(Contact)
        end
        it "returns a Contact object, with correct attributes" do
          contact = Contact.find(@id)
          expect(contact.id).to           eq @id
          expect(contact.name).to         eq @name
          expect(contact.email).to        eq @email
          expect(contact.birthdate).to    eq @birthdate
          expect(contact.phone_number).to eq @phone_number
          expect(contact.deleted).to      eq @deleted
        end
        it "returns correct attributes when finding for the second record" do
          name            = 'Maria'
          email           = 'maria@net.net'
          birthdate       = '1968-11-22'
          phone_number    = '2222-1111'
          deleted         = Contact::DELETED_OPTIONS[1]
          contact = Contact.new( name: name,
                                email: email,
                                birthdate: birthdate,
                                phone_number: phone_number )
          contact.save
          id = nil
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              id = line.split(";")[0] #gets the 2nd line (the last text file line)
            end
          end
          second_contact = Contact.find(id)
          expect(second_contact.id).to           eq id
          expect(second_contact.name).to         eq name
          expect(second_contact.email).to        eq email
          expect(second_contact.birthdate).to    eq birthdate
          expect(second_contact.phone_number).to eq phone_number
          expect(second_contact.deleted).to      eq deleted
        end
      end
    end
  end

  context '#find validation (deleted contact)'  do
    context 'with one deleted contact' do
      describe "and no parameter was given" do
        before :each do
          delete_file
          @name_01  = 'John Smith'; @email_01   = 'john_smith@gmail.net'; @bdate_01 = '2000-07-01';
          @phone_01 = '1111-2222';  @deleted_01 = Contact::DELETED_OPTIONS[1]
          @name_02  = 'Maria';      @email_02   = 'maria@net.net';        @bdate_02 = '1976-11-22';
          @phone_02 = '2111-1111';  @deleted_02 = Contact::DELETED_OPTIONS[1]
          @name_03  = 'Ana';        @email_03   = 'ana@net.net';          @bdate_03 = '1968-11-22';
          @phone_03 = '3111-1111';  @deleted_03 = Contact::DELETED_OPTIONS[0]
          @contact_01 = Contact.new( name: @name_01, email: @email_01,
                                    birthdate: @bdate_01, phone_number: @phone_01, deleted: @deleted_01 )
          @contact_01.save
          @contact_02 = Contact.new( name: @name_02, email: @email_02,
                                    birthdate: @bdate_02, phone_number: @phone_02, deleted: @deleted_02 )
          @contact_02.save
          @contact_03 = Contact.new( name: @name_03, email: @email_03,
                                    birthdate: @bdate_03, phone_number: @phone_03, deleted: @deleted_03 )
          @contact_03.save
        end
        it "returns an Array" do
          expect(Contact.find).to be_kind_of(Array)
        end
        it "returns an Array filled with 2 records" do
          expect(Contact.find.length).to eq 2
        end
        it "returns an Array of Contact kind" do
          contacts = Contact.find
          expect(contacts[0]).to be_kind_of(Contact)
          expect(contacts[1]).to be_kind_of(Contact)
        end
        it "returns a 2 records Array of Contact kind, with correct attributes" do
          contacts = Contact.find
          expect(Regexp.new(contacts[0].id)).to be_kind_of(Regexp)
          expect(contacts[0].name).to           eq @name_01
          expect(contacts[0].email).to          eq @email_01
          expect(contacts[0].birthdate).to      eq @bdate_01
          expect(contacts[0].phone_number).to   eq @phone_01
          expect(contacts[0].deleted).to        eq @deleted_01
          expect(contacts[1].name).to           eq @name_02
          expect(contacts[1].email).to          eq @email_02
          expect(contacts[1].birthdate).to      eq @bdate_02
          expect(contacts[1].phone_number).to   eq @phone_02
          expect(contacts[1].deleted).to        eq @deleted_02
        end
      end
      describe "and an id was given" do
        before :each do
          delete_file
          FactoryGirl.create(:contact, deleted: Contact::DELETED_OPTIONS[0])
          @id = nil
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              @id = line.split(";")[0]
            end
          end
        end
        it "returns an empty Array" do
          expect(Contact.find(@id)).to be_nil
        end
        it "returns correct attributes when finding for the second record" do
          name            = 'Maria'
          email           = 'maria@net.net'
          birthdate       = '1968-11-22'
          phone_number    = '2222-1111'
          deleted         = Contact::DELETED_OPTIONS[1]
          contact = Contact.new( name: name,
                                email: email,
                                birthdate: birthdate,
                                phone_number: phone_number )
          contact.save
          id = nil
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              id = line.split(";")[0] #gets the 2nd line (the last text file line)
            end
          end
          second_contact = Contact.find(id)
          expect(second_contact.id).to           eq id
          expect(second_contact.name).to         eq name
          expect(second_contact.email).to        eq email
          expect(second_contact.birthdate).to    eq birthdate
          expect(second_contact.phone_number).to eq phone_number
          expect(second_contact.deleted).to      eq deleted
        end
      end
    end
  end

  context '#save validation' do
    context 'when invalid content' do
      describe "and file path doesn't exist" do
        before :each do
          @contact = Contact.new
          delete_file
        end
        it "returns false" do
          expect(@contact.save).to be_falsy
        end
      end
      describe "and invalid attributes" do
        before :each do
          @contact = FactoryGirl.create(:contact, name: nil)
        end
        it "returns false" do
          expect(@contact.save).to be_falsy
        end
        it "returns errors messages" do
          @contact.save
          expect(@contact.errors.messages.empty?).to be_falsy
        end
      end
    end
    context 'when valid content' do
      describe "and file path exists" do
        before :each do
          delete_file
          @contact = FactoryGirl.build :contact
        end
        it "returns true" do
          expect(@contact.save).to be_truthy
        end
        it "generates a valid uuid code for contact.id" do
          uuid_reg_exp = /^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}/
          @contact.save
          expect(uuid_reg_exp.match(@contact.id)).not_to be_nil
        end
        it "saves all attributes properly" do
          @contact.save
          contact = []
          file = File.open(@rspec_file_path, 'r')
          file.each_line do |line|
            contact = line.chomp.split(";")
          end
          file.close
          expect(contact[1]).to eq @name
          expect(contact[2]).to eq @email
          expect(contact[3]).to eq @birthdate
          expect(contact[4]).to eq @phone_number
          expect(contact[5]).to eq @deleted
        end
      end
      describe "and there is a separator character" do
        before :each do
          delete_file
          @contact = FactoryGirl.build :contact, name: 'J;ohn Smith',
            email: 'john;_smith@gmail.net', birthdate: '2000;-07-01',
            phone_number: '1111-2222;'
        end
        it "returns true" do
          expect(@contact.save).to be_truthy
        end
        it "generates a valid uuid code for contact.id" do
          uuid_reg_exp = /^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}/
          @contact.save
          expect(uuid_reg_exp.match(@contact.id)).not_to be_nil
        end
        it "saves all attributes whithout separator character" do
          @contact.save
          contact = []
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              contact = line.chomp.split(";")
            end
          end
          expect(contact[1]).to eq @name
          expect(contact[2]).to eq @email
          expect(contact[3]).to eq @birthdate
          expect(contact[4]).to eq @phone_number
          expect(contact[5]).to eq @deleted
        end
      end
    end
  end

  context '#destroy validation' do
    context 'when invalid content' do
      describe "and file path doesn't exist" do
        before :each do
          @contact = FactoryGirl.create :contact
          delete_file
        end
        it "returns false" do
          expect(@contact.destroy).to be_falsy
        end
      end
      describe "and invalid attributes" do
        before :each do
          @contact = FactoryGirl.create(:contact, name: nil)
        end
        it "returns false" do
          expect(@contact.destroy).to be_falsy
        end
      end
      describe "and id is invalid" do
        before :each do
          @contact = FactoryGirl.create :contact
        end
        it "returns false" do
          @contact.id = '"xa0d22e8-e73a-418f-9b90-ffe678abb52x'
          expect(@contact.destroy).to be_falsy
        end
      end
    end
    context 'when valid content' do
      describe "and file path exists" do
        before :each do
          delete_file
          @contact = FactoryGirl.create :contact
        end
        it "returns true" do
          expect(@contact.destroy).to be_truthy
        end
        it "saves a deleted flag properly: set contact as deleted" do
          expect(@contact.destroy).to be_truthy
          contact = []
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              contact = line.chomp.split(";") # get just one line
            end
          end
          uuid_reg_exp = /^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}/
          expect(uuid_reg_exp.match(contact[0])).not_to be_nil
          expect(contact[1]).to eq @name
          expect(contact[2]).to eq @email
          expect(contact[3]).to eq @birthdate
          expect(contact[4]).to eq @phone_number
          expect(contact[5]).to eq Contact::DELETED_OPTIONS[0]
        end
      end
      describe "when there are many records and delete just one record" do
        before :each do
          delete_file
          @contact_01 = FactoryGirl.create :contact
          @contact_02 = FactoryGirl.create :contact, name: "Maryann"
          @contact_03 = FactoryGirl.create :contact, name: "Sue Hellen"
        end
        it "returns true" do
          expect(@contact_02.destroy).to be_truthy
        end
        it "set just one contact as deleted" do
          @contact_02.destroy
          contact = []
          counter = 1
          File.open(@rspec_file_path, 'r') do |file|
            file.each_line do |line|
              if counter == 2
                contact = line.chomp.split(";") # get just one line
              end
              counter += 1
            end
          end
          uuid_reg_exp = /^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}/
          expect(uuid_reg_exp.match(contact[0])).not_to be_nil
          expect(contact[1]).to eq "Maryann"
          expect(contact[2]).to eq @email
          expect(contact[3]).to eq @birthdate
          expect(contact[4]).to eq @phone_number
          expect(contact[5]).to eq Contact::DELETED_OPTIONS[0]
        end
      end
    end
  end

  context '#update validation' do
    context 'when invalid content' do
      describe "and file path doesn't exist" do
        before :each do
          @contact_01 = FactoryGirl.create :contact
          @contact_02 = FactoryGirl.create :contact
          delete_file
        end
        it "returns false" do
          expect(@contact_01.update(@contact_02)).to be_falsy
        end
      end
      describe "and invalid attributes" do
        before :each do
          delete_file
          @contact_01 = FactoryGirl.create :contact
          contact_02 = { name: @contact_01.name,           email: nil,
                         birthdate: @contact_01.birthdate, phone_number: @contact_01.phone_number }
          @result = @contact_01.update(contact_02)
        end
        it "returns false" do
          expect(@result).to be_falsy
        end
        it "returns message errors" do
          expect(@contact_01.errors.messages.empty?).to be_falsy
        end
      end
    end
    context 'when valid content' do
      describe "and changing name" do
        before :each do
          delete_file
          contact_01 = FactoryGirl.create :contact
          contact_02 = { name: "Mary",                    email: contact_01.email,
                         birthdate: contact_01.birthdate, phone_number: contact_01.phone_number }
          @result = contact_01.update(contact_02)
          contact_03 = FactoryGirl.create :contact, name: "Hellen"
        end
        it "returns true" do
          expect(@result).to be_truthy
        end
        it "returns updated name" do
          expect(Contact.find_by_name('Mary').length).to eq 1
        end
        it "returns not updated name" do
          expect(Contact.find_by_name('Hellen').length).to eq 1
        end
        it "returns total of 2 records" do
          expect(Contact.all.length).to eq 2
        end
      end
      describe "and update same contact many times" do
        before :each do
          delete_file
          contact_01 = FactoryGirl.create :contact
          contact_02 = { name: "Mary",                    email: contact_01.email,
                         birthdate: contact_01.birthdate, phone_number: contact_01.phone_number }
          contact_01.update(contact_02)
          contact_01 = Contact.find_by_name("Mary")
          contact_02 = { name: "Mary Hellen",                email: contact_01[0].email,
                         birthdate: contact_01[0].birthdate, phone_number: contact_01[0].phone_number }
          contact_01[0].update(contact_02)
          contact_01 = Contact.find_by_name("Mary Hellen")
          contact_02 = { name: contact_01[0].name,           email: contact_01[0].email,
                         birthdate: contact_01[0].birthdate, phone_number: '1111-2222' }
          contact_01[0].update(contact_02)
          contact_03 = FactoryGirl.create :contact, name: "Hellen"
        end
        it "returns zero for first updated name" do
          expect(Contact.find_by_name('Mary').length).to eq 0
        end
        it "returns one for last updated name" do
          expect(Contact.find_by_name('Mary Hellen').length).to eq 1
        end
        it "returns not updated name" do
          expect(Contact.find_by_name('Hellen').length).to eq 1
        end
        it "returns total of 2 records" do
          expect(Contact.all.length).to eq 2
        end
      end
    end
  end

  context '#count validation' do
    context 'when invalid content' do
      describe "and file path doesn't exist" do
        before :each do
          delete_file
        end
        it "returns false" do
          expect(Contact.count).to be_falsy
        end
      end
    end
    context 'when valid content' do
      describe "text file is empty" do
        before do
          delete_file
          FactoryGirl.build :contact
        end
        it "returns a number" do
          expect(Contact.count).to be_kind_of(Fixnum)
        end
        it "returns 0 records" do
          expect(Contact.count).to eq 0
        end
      end
      describe "text file has a record" do
        before do
          delete_file
          FactoryGirl.create :contact
        end
        it "returns a number" do
          expect(Contact.count).to be_kind_of(Fixnum)
        end
        it "returns 1 record" do
          expect(Contact.count).to eq 1
        end
      end
      describe "text file has 2 records, one is deleted" do
        before do
          delete_file
          FactoryGirl.create :contact
          FactoryGirl.create :contact, deleted: Contact::DELETED_OPTIONS[0]
        end
        it "returns a number" do
          expect(Contact.count).to be_kind_of(Fixnum)
        end
        it "returns 1 record" do
          expect(Contact.count).to eq 1
        end
      end
      describe "text file has 4 records, all of them are deleted" do
        before do
          delete_file
          FactoryGirl.create :contact, deleted: Contact::DELETED_OPTIONS[0]
          FactoryGirl.create :contact, deleted: Contact::DELETED_OPTIONS[0]
          FactoryGirl.create :contact, deleted: Contact::DELETED_OPTIONS[0]
          FactoryGirl.create :contact, deleted: Contact::DELETED_OPTIONS[0]
        end
        it "returns a number" do
          expect(Contact.count).to be_kind_of(Fixnum)
        end
        it "returns 0 records" do
          expect(Contact.count).to eq 0
        end
      end
    end
  end

end
