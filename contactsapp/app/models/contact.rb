class Contact
  include ActiveModel::Model

  attr_accessor :id, :name, :email, :birthdate, :phone_number, :deleted
  @@filepath = "db/#{ENV['RAILS_ENV']}.txt"
  DELETED_OPTIONS = %w(Y N)
  validates :name,         presence: true, length: { maximum: 50 }
  validates :email,        presence: true, format: { with: /(\A([a-z]*\s*)*\<*([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\>*\Z)/i }
  validates :phone_number, length: { maximum: 30 }
  validates :deleted,      :inclusion => {:in => DELETED_OPTIONS}
  validate  :is_birthdate_valid?

  def initialize(attributes = {})
    attributes.merge!({deleted: 'N'}) unless attributes.has_key?(:deleted)
    attributes = remove_delimiter( attributes )
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    create_file
  end

  def self.filepath
    @@filepath.nil? ? "" : @@filepath
  end

  def self.filepath=( filepath )
    @@filepath = filepath
  end

  def to_param
    self.id
  end

  def save!
    save
  end

  def save
    return false unless File.exist?(@@filepath)
    return false unless self.valid?
    id = @id ? @id : generate_id
    line = [id, @name, @email, @birthdate, @phone_number, @deleted].join(";")
    line << ";" unless line[-1,1] == ';' # must have a ; at the end of the line
    File.open(@@filepath, 'a') do |file|
      file.puts "#{line}\n"
    end
    return true
  end

  def destroy
    # set contact deleted flag to Y
    return false unless File.exist?(@@filepath)
    return false unless self.valid?
    f = File.new(@@filepath, 'r+')
    result = false
    f.each do |line|
      id      = line.split(';')[0]
      deleted = line.split(';')[5]
      if id == self.id && deleted == DELETED_OPTIONS[1]
        f.seek(-3, IO::SEEK_CUR)
        f.write("#{DELETED_OPTIONS[0]};")
        f.write("\n")
        result = true
      end
    end
    f.close
    return result
  end

  def update( contact_to_update = nil )
    return false unless File.exist?(@@filepath)
    return false unless self.valid?
    return false unless contact_to_update
    result = false
    contact = Contact.new( id: self.id, name: contact_to_update[:name],
                          email: contact_to_update[:email], birthdate: contact_to_update[:birthdate],
                          phone_number: contact_to_update[:phone_number] )
    if contact.valid?
      result = self.destroy && contact.save
    else
      unless contact.errors.messages.empty?
        self.errors.messages.merge!(contact.errors.messages)
      end
    end
    return result
  end

  def self.count
    # Count lines from file.
    # Counting for not deleted records.
    return false unless File.exist?(@@filepath)
    lines = IO.readlines(@@filepath).delete_if{ |e| e.split(";")[5] == DELETED_OPTIONS[0] }
    return lines.length
  end

  def self.all
    result = self.find
    return [] unless result
    return [result] unless result.instance_of? Array
    return result
  end

  def self.text_line_to_contact_instance( record_to_find = nil, find_for_name = false )
    contact = []
    File.readlines(@@filepath).each do |line|
      id, name, email, birthdate, phone_number, deleted = line.chomp.split(";")
      if deleted == DELETED_OPTIONS[1]
        if find_for_name
          found = name == (record_to_find ? record_to_find : name)
        else
          found = id == (record_to_find ? record_to_find : id)
        end
        if found
          contact << Contact.new( id: id, name: name, email: email,
                                 birthdate: birthdate, phone_number: phone_number )
        end
      end
    end
    return contact
  end

  def self.find_by_name( record_to_find = nil )
    # Read contact file, searching for name
    # Returns a contact instance
    return [] unless File.exist?(@@filepath)
    return [] unless record_to_find
    find_for_name = true
    contact = self.text_line_to_contact_instance( record_to_find, find_for_name )
    return contact
  end

  def self.find( record_to_find = nil )
    # Read contact file.
    # Returns a contact instance
    return [] unless File.exist?(@@filepath)
    contact = self.text_line_to_contact_instance( record_to_find )
    return nil if contact.empty?
    return contact[0] if contact.length == 1
    return contact
  end

  private

  def remove_delimiter( args )
    args.each { |k,e| args[k] = (e ? e.gsub(';','') : e) }
  end

  def generate_id
    self.id = SecureRandom.uuid
  end

  def is_birthdate_valid?
    if((birthdate.to_date rescue ArgumentError) == ArgumentError)
      errors.add(:birthdate, 'invalid birthdate')
    end
  end

  def create_file
    # class should know if the file exists
    unless File.exists?(@@filepath)
      File.open(@@filepath, 'w') do |file|
      end
    end
  end

end
